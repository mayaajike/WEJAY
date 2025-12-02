//
//  SignInSpotifyHelper.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/1/25.
//

import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

struct SpotifySignInResult {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: TimeInterval
    let scope: String
}

struct SpotifyImage: Decodable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyUserProfile: Decodable {
    let id: String
    let display_name: String?
    let email: String?
    let images: [SpotifyImage]?
}

final class SignInSpotifyHelper: NSObject, ASWebAuthenticationPresentationContextProviding {

    private var authSession: ASWebAuthenticationSession?
    
    // MARK: Public entry point
    @MainActor
    func signInSpotify() async throws -> SpotifySignInResult {
        // PKCE: generate verifier + challenge
        let codeVerifier = Self.generateCodeVerifier()
        let codeChallenge = Self.codeChallenge(for: codeVerifier)
        
        // authorize URL from APIService
        guard let authURL = SpotifyAPIService.shared.makeSpotifyAuthUrl(codeChallenge: codeChallenge) else {
            throw NetworkError.invalidURL
        }
        
        // begin system auth session
        let callbackURL = try await startAuthSession(authURL: authURL)
        
        // grab ?code=... from redirect URL
        guard let code = Self.queryItem(named: "code", in: callbackURL) else {
            throw NetworkError.invalidServerResponse
        }
        
        // exchange code for access + refresh tokens
        let tokens = try await SpotifyAPIService.shared.exchangeCodeForTokens(code: code, codeVerifier: codeVerifier)
        
        return tokens
    }
}

// MARK: OAuth core
extension SignInSpotifyHelper {
    
    @MainActor
    private func startAuthSession(authURL: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "wejay"
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let callbackURL = callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: NetworkError.invalidServerResponse)
                }
            }
            
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            self.authSession = session
            session.start()
        }
    }
    
    private static func queryItem(named name: String, in url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == name })?
            .value
    }
}

// MARK: PKCE helpers
extension SignInSpotifyHelper {
    
    private static func generateCodeVerifier() -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        var result = ""
        
        for _ in 0..<64 {
            if let random = chars.randomElement() {
                result.append(random)
            }
        }
        return result
    }
    
    private static func codeChallenge(for verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hashed = SHA256.hash(data: data)
        let hashData = Data(hashed)
        return hashData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
//  function to call refresh access tokens, willl grab access token from DB call function and update DB with new tokens
//    func refreshSpotifyIfNeeded(for user: DBUser) async {
//        guard let refreshToken = user.spotifyRefreshToken else { return }
//        
//        do {
//            let result = try await APIService.shared.refreshSpotifyAccessToken(refreshToken: refreshToken)
//            // Save new accessToken (+ maybe new refreshToken) back to Firestore
//            try await UserManager.shared.updateSpotifyTokens(
//                userId: user.userId,
//                accessToken: result.accessToken,
//                refreshToken: result.refreshToken
//            )
//        } catch {
//            print("Failed to refresh Spotify token:", error)
//        }
//    }
}

// MARK: DTO
private struct SpotifyTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let expires_in: Int
    let refresh_token: String?
}

// MARK: Presentation Anchor
extension SignInSpotifyHelper {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .keyWindow ?? UIWindow()
    }
}

