//
//  HomeViewModel.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/1/25.
//

import Foundation


@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var dbUser: DBUser? = nil
    @Published var selectedCategory: NavBarCategory? = nil
    @Published var products: [Product] = []
    @Published var productRows: [ProductRow] = []
    @Published var spotifyUser: SpotifyUserProfile? = nil
    
    var spotifyDisplayName: String? {
        // Prefer display_name, fall back to id if needed
        guard let user = spotifyUser else { return nil }
        
        if let name = user.display_name, !name.isEmpty {
            // use first name if there are spaces
            return name.split(separator: " ").first.map(String.init) ?? name
        } else {
            return "User \(user.id)"
        }
    }
    
    func loadInitialData() async {
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            
            let dbUser = try await UserManager.shared.getUser(userId: authUser.uid)
            self.dbUser = dbUser
            
            products = try await Array(DBHelper().getProducts().prefix(8))
            
            var rows: [ProductRow] = []
            let allBrands = Set(products.map({ $0.brand }))
            for brand in allBrands {
                rows.append(ProductRow(title: brand!.capitalized, products: products))
            }
            productRows = rows
        } catch {
            print("Failed to load initial data: \(error)")
        }
    }
    
    func selectCategory(_ category: NavBarCategory) {
        selectedCategory = category
    }
    
    // Spotify connection flow
    func connectSpotify() async {
        do {
            let spotifyHelper = SignInSpotifyHelper()
            let spotifyAuthResult = try await spotifyHelper.signInSpotify()
            
            // fetch user profile
            let spotifyProfile = try await SpotifyAPIService.shared.fetchSpotifyCurrentUser(accessToken: spotifyAuthResult.accessToken)
            
            // save to State and update UI
            self.spotifyUser = spotifyProfile
            
            
            // build SpotifyInfo using user profile data
            let expiresAt = Date().addingTimeInterval(spotifyAuthResult.expiresIn)
            let profileImageUrl = spotifyProfile.images?.first?.url
            
            let spotifyInfo = SpotifyInfo(
                id: spotifyProfile.id,
                displayName: spotifyProfile.display_name,
                email: spotifyProfile.email,
                profilePhotoUrl: profileImageUrl,
                accessToken: spotifyAuthResult.accessToken,
                refreshToken: spotifyAuthResult.refreshToken,
                scope: spotifyAuthResult.scope,
                expiresAt: expiresAt
            )
            
            // get current Firebase auth user
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            
            // save to FireStore
            try await UserManager.shared.updateSpotifyInfo(userId: authUser.uid, spotify: spotifyInfo)
            
            
            print("Spotify connected")
        } catch {
            print("Spotify sign-in failed, \(error)")
        }
    }
}
