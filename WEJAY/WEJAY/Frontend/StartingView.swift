//
//  StartingView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/25/25.
//

import SwiftUI
import SwiftfulUI
import SwiftfulRouting

struct StartingView: View {
    
    @State private var users: [Userr] = []
    @State private var products: [Product] = []
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(products) { product in
                    Text(product.title)
                        .foregroundStyle(.appGreen)
                }
            }
        }
        .padding()
        .task {
            await getData()
        }
    }
    
    private func getData() async {
        do {
            users = try await DBHelper().getUsers()
            products = try await DBHelper().getProducts()
        } catch {
            
        }
    }
}

#Preview {
    StartingView()
}
