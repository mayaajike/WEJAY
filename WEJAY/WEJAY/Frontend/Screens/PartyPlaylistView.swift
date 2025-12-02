//
//  PartyPlaylistView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/30/25.
//

import SwiftUI
import SwiftfulUI
import SwiftfulRouting

struct PartyPlaylistView: View {
    
    @Environment(\.router) var router
    
    var product: Product = .mock
    var user: DBUser
    
    @State private var products: [Product] = []
    @State private var showHeader: Bool = false
    
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(spacing: 12) {
                    PlaylistHeaderCell(
                        height: 250,
                        title: product.title,
                        subtitle: product.brand!,
                        imageName: product.thumbnail
                    )
                    .readingFrame { frame in
                        showHeader = frame.maxY < 150
                    }

                    
                    PlaylistDescriptionCell(
                        descriptionText: product.description,
                        userName: user.username?.first ?? "Guest",
                        subHeadline: product.category,
                        onAddToPlaylistPressed: nil,
                        onDownloadPressed: nil,
                        onSharePressed: nil,
                        onEllipsisPressed: nil,
                        onShufflePressed: nil,
                        onPlayPressed: nil
                    )
                    .padding(.horizontal, 16)
                    
                    ForEach(products) { product in
                        SongRowCell(
                            imageSize: 50,
                            imageName: product.firstImage,
                            title: product.title,
                            subtitle: product.brand,
                            onCellPressed: {
                                
                            },
                            onEllipsisPressed: {
                                
                            }
                        )
                        .padding(.leading, 16)
                    }
                        
                }
            }
            .scrollIndicators(.hidden)
            
            header
                .frame(maxHeight: .infinity, alignment: .top)
            
        }
        .task {
            await getData()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func getData() async {
        do {
            products = try await DBHelper().getProducts()
        } catch {
            print("Failed to fetch products: ", error)
        }
    }
    
    private var header: some View {
        ZStack {
            Text(product.title)
                .font(.headline)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.appBlack)
                .offset(y: showHeader ? 0 : -40)
                .opacity(showHeader ? 1 : 0)
            
            Image(systemName: "chevron.left")
                .font(.title3)
                .padding(10)
                .background(showHeader ? Color.black.opacity(0.001) : Color.appGray.opacity(0.7))
                .clipShape(Circle())
                .onTapGesture {
                    router.dismissScreen()
                }
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.appWhite)
        .animation(.smooth(duration: 0.2), value: showHeader)

    }
}

#Preview {
    let mockUser = DBUser(
            userId: "preview-user-id",
            email: "maya@example.com",
            username: UserName(first: "Maya", last: "Ody-Ajike"),
            photoUrl: nil,
            dateCreated: Date(),
            isPremium: false,
            genres: ["Afrobeats", "Hip-Hop"],
            role: .dj,
            spotify: nil
        )
    
    PartyPlaylistView(user: mockUser)
}
