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
    @Published var spotifyInfo: SpotifyInfo? = nil
    @Published var appleMusicInfo: AppleMusicInfo? = nil
    @Published var activeParties: [Party] = []
    
    var isSpotifyConnected: Bool {
        spotifyInfo?.isConnected == true
    }
    
    var spotifyButtonDisplayTitleOverride: String? {
        guard let info = spotifyInfo, info.isConnected else {
            return nil
        }
        return info.displayName?.isEmpty == false ? info.displayName : "Connected"
    }
    
    var appleMusicButtonDisplayTitleOverride: String? {
        guard let info = appleMusicInfo, info.isConnected else {
            // Not connected -> default tag on button
            return nil
        }
        
        if let firstName = dbUser?.username?.first, !firstName.isEmpty {
            return firstName
        } else {
            return "Connected"
        }
    }
    
    func loadInitialData() async {
        do {
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            
            let dbUser = try await UserManager.shared.getUser(userId: authUser.uid)
            self.dbUser = dbUser
            
            // If this is a DJ, also load their active parties
            if dbUser.role == .dj {
                await refreshActiveParties()
            }
            
            self.spotifyInfo = dbUser.spotify
            self.appleMusicInfo = dbUser.appleMusic
            
            // refresh access tokens i needed
            await refreshSpotifyIfNeeded()
            
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
                expiresAt: expiresAt,
                isConnected: true
            )
            
            // get current Firebase auth user
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            
            // save to FireStore
            try await UserManager.shared.updateSpotifyInfo(userId: authUser.uid, spotify: spotifyInfo)
            
            // update state variable
            self.spotifyInfo = spotifyInfo
            
            
            print("Spotify connected")
        } catch {
            print("Spotify sign-in failed, \(error)")
        }
    }
    
    func refreshSpotifyIfNeeded() async {
        guard let currentSpotify = spotifyInfo,
              currentSpotify.isConnected else {
            return
        }
        
        let now = Date()
        
        // if token is still valid break
        if currentSpotify.expiresAt > now {
            return
        }
        
        // grab refresh token to refresh access token
        guard let refreshToken = currentSpotify.refreshToken,
              !refreshToken.isEmpty else {
            print("Spotify access token expired and no refresh token available.")
            return
        }
        
        do {
            // ask APIService to refresh the token
            let tokenResponse = try await SpotifyAPIService.shared.refreshAccessToken(refreshToken: refreshToken)
            
            let newExpiresAt = Date().addingTimeInterval(tokenResponse.expiresIn)

            let updatedSpotifyInfo = SpotifyInfo(
                id: currentSpotify.id,
                displayName: currentSpotify.displayName,
                email: currentSpotify.email,
                profilePhotoUrl: currentSpotify.profilePhotoUrl,
                accessToken: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken ?? currentSpotify.refreshToken,
                scope: tokenResponse.scope,
                expiresAt: newExpiresAt,
                isConnected: true
            )
            
            // save to db
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.updateSpotifyInfo(userId: authUser.uid, spotify: updatedSpotifyInfo)
            
            self.spotifyInfo = updatedSpotifyInfo
            
            print("Spotify token refreshed")
        } catch {
            print("Failed to refresh spotify token: \(error)")
        }
    }
    
    // Apple music connection flow
    func connectAppleMusic() async {
        do {
            let appleMusicHelper = AppleMusicHelper()
            let info = try await appleMusicHelper.appleMusicConnect()
            
            let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.updateAppleMusicInfo(userId: authUser.uid, appleMusic: info)
            
            self.appleMusicInfo = info
            print("Apple Music connected: ", info)
        } catch {
            print("Apple Music connection failed: ", error)
        }
    }
    
    // MARK: DJHOMESCREEN functions
    func refreshActiveParties() async {
        guard let user = dbUser, user.role == .dj else { return }
        
        do {
            let parties = try await PartyManager.shared.getActiveParties(forDJ: user.userId)
            self.activeParties = parties
        } catch {
            print("Error loading active parties:", error)
        }
    }
    
}
