//
//  UserManager.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/24/25.
//

import Foundation
import FirebaseFirestore

struct UserName: Codable {
    var first: String?
    var last: String?
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
    let isConnected: Bool
}

struct AppleMusicInfo: Codable {
    let isConnected: Bool
    let lastUpdated: Date
}

struct DBUser: Codable {
    let userId: String
    let email: String?
    let photoUrl: URL?
    let dateCreated: Date?
    let isPremium: Bool?
    let genres: [String]?
    let role: UserRole?
    let spotify: SpotifyInfo?
    let appleMusic: AppleMusicInfo?
    let profilePictureUrl: String?
    
    var username: UserName?
    
    var firstName: String? {
        username?.first
    }
    
    var lastName: String? {
        username?.last
    }
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.isPremium = false
        self.genres = nil
        self.role = nil
        self.spotify = nil
        self.appleMusic = nil
        self.profilePictureUrl = nil
        
        if auth.firstName != nil || auth.lastName != nil {
            self.username = UserName(first: auth.firstName, last: auth.lastName)
        } else {
            self.username = nil
        }
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
        spotify: SpotifyInfo? = nil,
        appleMusic: AppleMusicInfo? = nil,
        profilePictureUrl: String? = nil
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
        self.appleMusic = appleMusic
        self.profilePictureUrl = profilePictureUrl
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
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }
        
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
    
    func updateAppleMusicInfo(userId: String, appleMusic: AppleMusicInfo) async throws {
        let data = try encoder.encode(appleMusic)
        
        let dict: [String: Any] = [
            "apple_music": data
        ]
        
        try await userDocument(userId: userId).updateData(dict)
    }
    
    func updateUserProfileImage(userId: String, url: String) async throws {
        let data: [String: Any] = [
            "profile_picture_url": url
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
}
