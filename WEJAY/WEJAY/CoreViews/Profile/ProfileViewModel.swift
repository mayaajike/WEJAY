//
//  ProfileViewModel.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/30/25.
//

import Foundation
import PhotosUI
import _PhotosUI_SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var role: UserRole? = nil
    @Published var newGenre: String = ""
    @Published var hasError: Bool = false
    
    var isProfileComplete: Bool {
        let hasFirst = !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasLast = !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return hasFirst && hasLast && role != nil
    }
    
    var displayName: String {
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !first.isEmpty || !last.isEmpty {
            return [first, last].joined(separator: " ").trimmingCharacters(in: .whitespaces)
        } else if let email = user?.email {
            return email
        } else {
            return "New user"
        }
    }
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
            self.firstName = user?.username?.first ?? ""
            self.lastName = user?.username?.last ?? ""
            self.role = user?.role ?? nil
        } catch {
            print("Error loading user: \(error)")
            self.hasError = true
        }
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addFavoriteGenre(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addFavoriteGenre(userId: user.userId, genres: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeFavoriteGenre(text: String) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.removeFavoriteGenre(userId: user.userId, genres: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func saveName() {
        guard let user else { return }
        
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedFirst.isEmpty, !trimmedLast.isEmpty else { return }
        
        let username = UserName(first: trimmedFirst, last: trimmedLast)
        
        Task {
            try await UserManager.shared.addUsername(userId: user.userId, username: username)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func saveNewGenre() {
        guard let user else { return }
        let trimmed = newGenre.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        Task {
            try await UserManager.shared.addFavoriteGenre(userId: user.userId, genres: trimmed)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            await MainActor.run {
                self.newGenre = ""
            }
        }
    }
    
    func updateUserRole(to newRole: UserRole) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserRole(userId: user.userId, role: newRole)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            self.role = self.user?.role
        }
    }
        
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }
        
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else { return }
                let photoUrl = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
                try await UserManager.shared.updateUserProfileImage(userId: user.userId, url: photoUrl)
                self.user = try await UserManager.shared.getUser(userId: user.userId)
            } catch {
                print("Error saving profile image: ", error)
            }
        }
    }
    
}
