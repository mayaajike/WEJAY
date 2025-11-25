//
//  ProfileView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI

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

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignUpView: Bool
    
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
        ProfileView(showSignUpView: .constant(false))
    }
}
