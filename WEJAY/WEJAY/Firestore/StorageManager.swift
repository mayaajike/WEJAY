//
//  StorageManager.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/4/25.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(userId: String) -> StorageReference {
        imagesReference.child(userId)
    }
    
//    func getData(userId: String, url: String) async throws -> Data {
//        try await storage.child(url).data(maxSize: 3 * 1024 * 1024)
//    }
    
    func getData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func saveImage(data: Data, userId: String) async throws -> String {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "profile_photo.jpeg"
        let ref = userReference(userId: userId).child(path)
        
        _ = try await ref.putDataAsync(data, metadata: meta)
        
        let url = try await ref.downloadURL()
        return url.absoluteString
        
//        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
//            throw URLError(.badServerResponse)
//        }
//        
//        return (returnedPath, returnedName)
    }
    
    func saveImage(image: UIImage, userId: String) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        return try await saveImage(data: data, userId: userId)
    }
}
