//
//  ProfileView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI
import SwiftfulRouting

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignUpView: Bool
    @Environment(\.router) var router
    
    let genreOptions: [String] = ["Hip-Hop", "Rap", "Afrobeats"]
    
    private func genreIsSelected(text: String) -> Bool {
        viewModel.user?.genres?.contains(text) == true
    }
    
    let roleOptions: [UserRole] = [.dj, .guest]
    
    private func roleIsSelected(_ role: UserRole) -> Bool {
        viewModel.user?.role == role
    }
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("ID: \(user.userId)")
                
                if let email = user.email {
                    Text("Email: \(email.description)")
                }
                
                Button {
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("Premium Status: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    if viewModel.firstName.isEmpty && viewModel.lastName.isEmpty {
                        Text("Add your name so everyone knows its you!")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("First Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter first name", text: $viewModel.firstName)
                        .textContentType(.givenName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                    
                    Text("Last Name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter last name", text: $viewModel.lastName)
                        .textContentType(.familyName)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                    
                    Button {
                        // handle update in FireStore
                        if user.username == nil {
                            viewModel.addUsername()
                        }
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .font(.headline)
                    }
                    .background(
                        (viewModel.user?.username != nil ? Color.gray : Color.purple)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 8)
                    
                }
            
                VStack {
                    HStack {
                        ForEach(genreOptions, id: \.self) { string in
                            Button(string) {
                                if genreIsSelected(text: string) {
                                    viewModel.removeFavoriteGenre(text: string)
                                } else {
                                    viewModel.addFavoriteGenre(text: string)
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(genreIsSelected(text: string) ? .purple : .gray)
                        }
                    }
                    
                    Text("Favorite genres: \((user.genres ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack {
                    HStack {
                        ForEach(roleOptions, id: \.self) { option in
                            Button(option.rawValue.capitalized) {
                                viewModel.updateUserRole(to: option)
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(roleIsSelected(option) ? .purple : .gray)
                        }
                    }
                    
                    Text("Role: \((viewModel.user?.role?.rawValue.capitalized ?? "Not Set"))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
            
                Button {
                    router.showScreen(.fullScreenCover) { _ in
                        HomeView(showSignUpView: $showSignUpView)
                    }
                } label: {
                    Text("Go to Home Page")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .font(.headline)
                }
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 8)

            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignUpView: $showSignUpView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RouterView { _ in
            ProfileView(showSignUpView: .constant(false))
        }
    }
}
