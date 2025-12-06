//
//  PartyManager.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/5/25.
//

import Foundation
import FirebaseFirestore

struct Party: Codable, Identifiable {
    @DocumentID var id: String?
    let djId: String
    let name: String
    let description: String?
    let coverImageUrl: String?
    let createdAt: Date
    let isActive: Bool
    let guestIds: [String]?
    
    // New Spotify fields
    let spotifyPlaylistId: String?
    let spotifyPlaylistUrl: String?
    let spotifyPlaylistUri: String?
    
    init(
        id: String? = nil,
        djId: String,
        name: String,
        description: String? = nil,
        coverImageUrl: String? = nil,
        createdAt: Date = Date(),
        isActive: Bool = true,
        guestIds: [String]? = [],
        spotifyPlaylistId: String? = nil,
        spotifyPlaylistUrl: String? = nil,
        spotifyPlaylistUri: String? = nil
    ) {
        self.id = id
        self.djId = djId
        self.name = name
        self.description = description
        self.coverImageUrl = coverImageUrl
        self.createdAt = createdAt
        self.isActive = isActive
        self.guestIds = guestIds
        self.spotifyPlaylistId = spotifyPlaylistId
        self.spotifyPlaylistUrl = spotifyPlaylistUrl
        self.spotifyPlaylistUri = spotifyPlaylistUri
    }
}

final class PartyManager {
    
    static let shared = PartyManager()
    private init() { }
    
    private let partyCollection = Firestore.firestore().collection("parties")
    
    private func partyDocument(partyId: String) -> DocumentReference {
        partyCollection.document(partyId)
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
    
    // MARK: - Create Party
    func createParty(
        dj: DBUser,
        name: String,
        description: String?,
        coverImageData: Data?
    ) async throws -> Party {

        let docRef = partyCollection.document()
        let partyId = docRef.documentID
        
       
        var coverUrl: String? = nil
        if let data = coverImageData {
            coverUrl = try await StorageManager.shared.saveImage(data: data, userId: partyId)
        }
        
        // Optional Spotify playlist creation
        var spotifyPlaylistId: String? = nil
        var spotifyPlaylistUrl: String? = nil
        var spotifyPlaylistUri: String? = nil
        
        if let spotify = dj.spotify, spotify.isConnected {
            // NOTE: assumes spotify.accessToken is already fresh.
            // You can plug in your refresh logic here if needed.
            let playlistResponse = try await SpotifyAPIService.shared.createPlaylist(
                accessToken: spotify.accessToken,
                userId: spotify.id,
                name: name,
                description: description
            )
            
            spotifyPlaylistId = playlistResponse.id
            spotifyPlaylistUri = playlistResponse.uri
            spotifyPlaylistUrl = playlistResponse.external_urls?.spotify
        }

        let party = Party(
            id: partyId,
            djId: dj.userId,
            name: name,
            description: description,
            coverImageUrl: coverUrl,
            createdAt: Date(),
            isActive: true,
            guestIds: [],
            spotifyPlaylistId: spotifyPlaylistId,
            spotifyPlaylistUrl: spotifyPlaylistUrl,
            spotifyPlaylistUri: spotifyPlaylistUri
        )
        
        try docRef.setData(from: party, merge: false, encoder: encoder)
        
        return party
    }
        
    
    func getParty(partyId: String) async throws -> Party {
        try await partyDocument(partyId: partyId).getDocument(as: Party.self, decoder: decoder)
    }
    
    func addGuest(partyId: String, guestUserId: String) async throws {
        let data: [String: Any] = [
            "guest_ids": FieldValue.arrayUnion([guestUserId])
        ]
        
        try await partyDocument(partyId: partyId).updateData(data)
    }
    
    func removeGuest(partyId: String, guestUserId: String) async throws {
        let data: [String: Any] = [
            "guest_ids": FieldValue.arrayRemove([guestUserId])
        ]
        
        try await partyDocument(partyId: partyId).updateData(data)
    }
    
    func endParty(partyId: String) async throws {
        let data: [String: Any] = [
            "is_active": false
        ]
        
        try await partyDocument(partyId: partyId).updateData(data)
    }
    
    func getActiveParties(forDJ djId: String) async throws -> [Party] {
        let snapshot = try await partyCollection
            .whereField("dj_id", isEqualTo: djId)
            .whereField("is_active", isEqualTo: true)
            .order(by: "created_at", descending: true)
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: Party.self, decoder: decoder)
        }
    }
}

