//
//  UserManager.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/24/25.
//

import Foundation
import FirebaseFirestore

struct UserName: Codable {
    let first: String?
    let last: String?
}

enum UserRole: String, Codable {
    case guest
    case dj
}

struct SpotifyInfo: Codable {
    let id: String
    let displayName: String?
    let email: String?
    let profilePhotoUrl: String?
    let accessToken: String
    let refreshToken: String?
    let scope: String
    let expiresAt: Date
}

struct DBUser: Codable {
    let userId: String
    let email: String?
    let username: UserName?
    let photoUrl: URL?
    let dateCreated: Date?
    let isPremium: Bool?
    let genres: [String]?
    let role: UserRole?
    let spotify: SpotifyInfo?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.username = nil
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.genres = nil
        self.role = nil
        self.spotify = nil
    }
    
    init(
        userId: String,
        email: String? = nil,
        username: UserName? = nil,
        photoUrl: URL? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        genres: [String]? = nil,
        role: UserRole? = nil,
        spotify: SpotifyInfo? = nil
    ) {
        self.userId = userId
        self.email = email
        self.username = username
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.genres = genres
        self.role = role
        self.spotify = spotify
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "user_id": auth.uid,
//            "date_created": Timestamp(),
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userId: userId).getDocument()
//        
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? URL
//        let dateCreated = data["date_created"] as? Date
//        
//        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        let data: [String:Any] = [
            "is_premium": isPremium
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addFavoriteGenre(userId: String, genres: String) async throws {
        let data: [String:Any] = [
            "genres": FieldValue.arrayUnion([genres])
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func removeFavoriteGenre(userId: String, genres: String) async throws {
        let data: [String:Any] = [
            "genres": FieldValue.arrayRemove([genres])
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addUsername(userId: String, username: UserName) async throws {
        let data = try encoder.encode(username)
        
        let dict: [String:Any] = [
            "username": data
        ]
        
        try await userDocument(userId: userId).updateData(dict)
    }
    
    func addUserRole(userId: String, role: UserRole) async throws {
        let data: [String:Any] = [
            "role": role.rawValue
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateSpotifyInfo(userId: String, spotify: SpotifyInfo) async throws {
        let data = try encoder.encode(spotify)
        
        let dict: [String: Any] = [
            "spotify": data
        ]
        
        try await userDocument(userId: userId).updateData(dict)
    }
}
