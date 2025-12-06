//
//  HomeView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/25/25.
//

import SwiftUI
import SwiftfulUI
import SwiftfulRouting

struct HomeView: View {
    
    @Binding var showSignUpView: Bool
    @Environment(\.router) var router
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(
                    spacing: 1,
                    pinnedViews: [.sectionHeaders],
                    content: {
                        Section {
                            VStack(spacing: 16) {
                                guideBarSection
                                    .padding(.horizontal, 16)
                                
                                if let product = viewModel.products.first {
                                    recentPartySection(product: product)
                                        .padding(.horizontal, 16)
                                }
                                
                                prevPartyRows
                            }
                        } header: {
                            header
                        }
                    })
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .clipped()
            
        }
        .task {
            await viewModel.loadInitialData()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
        
    private var header: some View {
        HStack(spacing: 16) {
            // MARK: Profile Image (Fixed NaN Crash)
            ZStack {
                if let user = viewModel.dbUser,
                   let url = user.profilePictureUrl {
                    
                    // FIX: Applied explicit frame DIRECTLY to the loader
                    ImageLoaderView(urlString: url)
                        .frame(width: 35, height: 35)
                        .background(Color.appWhite)
                        .clipShape(Circle())
                        .onTapGesture {
                            router.showScreen(.push) { _ in
                                ProfileView(showSignUpView: $showSignUpView)
                            }
                        }
                } else {
                    // Fallback avatar
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35) // Explicit frame here too
                        .foregroundStyle(Color.appWhite)
                        .onTapGesture {
                            router.showScreen(.push) { _ in
                                ProfileView(showSignUpView: $showSignUpView)
                            }
                        }
                }
            }
            // Keep this frame on the container as a safety net
            .frame(width: 35, height: 35)
            
            
            // categories
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(NavBarCategory.allCases, id: \.self) { category in
                        NavScrollBarCell(
                            message: category.rawValue.capitalized,
                            isSelected: category == viewModel.selectedCategory
                        )
                        .onTapGesture {
                            viewModel.selectCategory(category)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            
            // settings
            Button {
                router.showScreen(.push) { _ in
                    SettingsView(showSignUpView: $showSignUpView)
                }
            } label : {
                Image(systemName: "gearshape")
                    .font(.callout)
                    .foregroundStyle(Color.appWhite)
                    .frame(minWidth: 40, minHeight: 35)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .themeColors(isSelected: false)
                    .cornerRadius(23)
            }
        }
        .padding(.vertical, 24)
        .padding(.leading, 10)
        .padding(.trailing, 8)
        .background(Color.appBlack)
    }
    
    

    private var guideBarSection: some View {
        VStack(spacing: 12) {
            // Top row Apple Music + Spotify
            HStack(spacing: 12) {
                GuideBarCell(option: .spotify, titleOverride: viewModel.spotifyButtonDisplayTitleOverride) {
                    Task {
                        guard !viewModel.isSpotifyConnected else { return }
                        await viewModel.connectSpotify()
                    }
                }
              
                GuideBarCell(option: .appleMusic, titleOverride: viewModel.appleMusicButtonDisplayTitleOverride) {
                    // TODO: Join developer program and test auth flow
                    Task {
                        await viewModel.connectAppleMusic()
                    }
                }
            }
           
            // Bottom row share button
            GuideBarCell(option: .share, titleOverride: nil) {
                // TODO: share party flow
            }
        }
    }
    
    
    private func goToPlaylistView(product: Product) {
        guard let user = viewModel.dbUser else { return }
        
        router.showScreen(.push) { _ in
                PartyPlaylistView(product: product, user: user)
        }
    }
    
    private func recentPartySection(product: Product) -> some View {
        CurrentPartyCell(
            imageName: product.firstImage,
            headline: product.brand,
            subheadline: product.category,
            title: product.title,
            subtitle: product.description,
            onAddToPlaylistPressed: {
              
            },
            onPlayPressed: {
                goToPlaylistView(product: product)
            }
        )
    }
    
    private var prevPartyRows: some View {
        ForEach(viewModel.productRows) { row in
            VStack(spacing: 8) {
                Text(row.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
              
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(row.products) { product in
                            PreviousPartyCell(
                                imageSize: 120,
                                imageName: product.firstImage,
                                title: product.title
                            )
                            .asButton(.press) {
                                goToPlaylistView(product: product)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RouterView { _ in
            HomeView(showSignUpView: .constant(false))
        }
    }
}
