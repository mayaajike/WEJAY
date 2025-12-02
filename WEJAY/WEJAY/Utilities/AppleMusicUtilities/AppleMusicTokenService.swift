//
//  AppleMusicTokenService.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/1/25.
//

import Foundation

final class AppleMusicTokenService {
    
    static let shared = AppleMusicTokenService()
    
    private init() {}
    
    // Real world implementation would make a call to backend
    // dummy data now until enrollment in Apple Developers Program
    func fetchDeveloperToken() async throws -> String {
        // TODO: Replace this with a real https call to the server
        // throwing error for now
        print("Join Apple Developer Program")
        throw NetworkError.generalError
    }
}

// example for future
//func fetchDeveloperToken() async throws -> String {
//    let url = URL(string: "url-to-backend-server.com/apple-music/developer-token")!
//    let (data, response) = try await URLSession.shared.data(from: url)
//    //decode string from JSON
//    return ""
//}
