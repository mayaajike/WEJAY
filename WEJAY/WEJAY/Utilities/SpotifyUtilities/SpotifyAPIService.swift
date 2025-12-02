//
//  APIService.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/1/25.
//

import Foundation

class SpotifyAPIService {
    
    static let shared = SpotifyAPIService()
    
    // Builds authorize url for the PKCE flow
    func makeSpotifyAuthUrl(codeChallenge: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyAPIConstants.authHost
        components.path = "/authorize"
        
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: SpotifyAPIConstants.clientId),
            URLQueryItem(name: "redirect_uri", value: SpotifyAPIConstants.redirectUri),
            URLQueryItem(name: "scope", value: SpotifyAPIConstants.scope),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: codeChallenge)
        ]
        
        return components.url
    }
    
    func exchangeCodeForTokens(code: String, codeVerifier: String) async throws -> SpotifySignInResult {
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyAPIConstants.authHost
        components.path = "/api/token"
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Body parameters for Auth Code + PKCE
        let bodyParams: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": SpotifyAPIConstants.redirectUri,
            "client_id": SpotifyAPIConstants.clientId,
            "code_verifier": codeVerifier
        ]
        
        request.httpBody = formURLEncodedBody(from: bodyParams)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        return try decodeSpotifyTokenResponse(data: data, response: response)

    }
    
    // refresh access token
    func refreshAccessToken(refreshToken: String) async throws -> SpotifySignInResult {
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyAPIConstants.authHost
        components.path = "/api/token"
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let bodyParams: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": SpotifyAPIConstants.clientId,
        ]
        
        request.httpBody = formURLEncodedBody(from: bodyParams)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // new refresh_token may or may not be returned here
        var result = try decodeSpotifyTokenResponse(data: data, response: response)
        
        // if no new refresh_token is given, retain the previous one
        if result.refreshToken == nil {
            result = SpotifySignInResult(
                accessToken: result.accessToken,
                refreshToken: refreshToken,
                expiresIn: TimeInterval(
                    result.expiresIn
                ),
                scope: result.scope
            )
        }
        
        return result
        
    }
    
    // Helpers
    
    private func formURLEncodedBody(from params: [String: String]) -> Data? {
        let bodyString = params
            .map { key, value in
                "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }
            .joined(separator: "&")
        
        return bodyString.data(using: .utf8)
    }
    
    private func decodeSpotifyTokenResponse(data: Data, response: URLResponse) throws -> SpotifySignInResult {
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "No body"
            print("Spotify token error:", raw)
            throw NetworkError.invalidServerResponse
        }
        
        let decoded = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
        
        return SpotifySignInResult(
            accessToken: decoded.access_token,
            refreshToken: decoded.refresh_token,
            expiresIn: TimeInterval(decoded.expires_in),
            scope: decoded.scope
        )
    }
}

// DTO
private struct SpotifyTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let expires_in: Int
    let refresh_token: String?
}

struct SpotifyTokenRefreshResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: TimeInterval
    let scope: String?
    let refresh_token: String?
    
    var accessToken: String { access_token }
    var expiresIn: TimeInterval { expires_in }
}

extension SpotifyAPIService {
    func fetchSpotifyCurrentUser(accessToken: String) async throws -> SpotifyUserProfile {
        var components = URLComponents()
        components.scheme = "https"
        components.host = SpotifyAPIConstants.apiHost
        components.path = "/v1/me"
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "No body"
            print("Spotify /me error: ", raw)
            throw NetworkError.invalidServerResponse
        }
        
        let profile = try JSONDecoder().decode(SpotifyUserProfile.self, from: data)
        
        return profile
    }
}
