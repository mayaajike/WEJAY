//
//  ProfileViewModel.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/30/25.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var role: UserRole? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        self.firstName = user?.username?.first ?? ""
        self.lastName = user?.username?.last ?? ""
        self.role = user?.role ?? nil
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
    
    func addUsername() {
        guard let user else { return }
        let username = UserName(first: firstName, last: lastName)
        
        Task {
            try await UserManager.shared.addUsername(userId: user.userId, username: username)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func updateUserRole(to newRole: UserRole) {
        guard let user else { return }
        
        Task {
            try await UserManager.shared.addUserRole(userId: user.userId, role: newRole)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
            self.role = user.role ?? nil
        }
    }
    
}
