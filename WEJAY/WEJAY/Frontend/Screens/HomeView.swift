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
    
    @State private var currentUser: Userr? = nil
    @State private var selectedCategory: NavBarCategory? = nil
    @State private var products: [Product] = []
    @State private var productRows: [ProductRow] = []
    
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
                                
                                if let product = products.first {
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
            await getData()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func getData() async {
        do {
            currentUser = try await DBHelper().getUsers().first
            products = try await Array(DBHelper().getProducts().prefix(8))
            
            var rows: [ProductRow] = []
            let allBrands = Set(products.map({ $0.brand }))
            for brand in allBrands {
                rows.append(ProductRow(title: brand!.capitalized, products: products))
            }
            productRows = rows
        } catch {
            
        }
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            // profile image
            ZStack {
                if let currentUser {
                    ImageLoaderView(urlString: currentUser.image)
                        .background(.appWhite)
                        .clipShape(Circle())
                        .onTapGesture {
                            router.showScreen(.push) { _ in
                                ProfileView(showSignUpView: $showSignUpView)
                            }
                        }
                }
            }
            .frame(width: 35, height: 35)
            
            // categories
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(NavBarCategory.allCases, id: \.self) { category in
                        NavScrollBarCell(
                            message: category.rawValue.capitalized,
                            isSelected: category == selectedCategory
                        )
                        .onTapGesture {
                            selectedCategory = category
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
                    .foregroundStyle(.appWhite)
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
        NonLazyVGrid(columns: 2, alignment: .center, spacing: 10, items: products) { product in
            if let product {
                GuideBarCell (imageName: product.firstImage, title: product.title)
                    .asButton(.press) {
                        
                    }
            }
        }
    }
    
    private func goToPlaylistView(product: Product) {
        guard let currentUser else { return }
        
        router.showScreen(.push) { _ in
                PartyPlaylistView(product: product, user: currentUser)
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
        ForEach(productRows) { row in
            VStack(spacing: 8) {
                Text(row.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.appWhite)
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
