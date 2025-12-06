//
//  ProfileView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI
import SwiftfulRouting
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignUpView: Bool
    @Environment(\.router) var router
    
    let genreOptions: [String] = ["Hip-Hop", "Rap", "Afrobeats"]
    let roleOptions: [UserRole] = [.dj, .guest]
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var imageData: Data?
    
    private var sectionBackgroundColor: Color {
        Color.purple.opacity(0.12)
    }
    
    // MARK: - Main Body
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection(user: user)
                        nameInputSection
                        roleSelectionSection
                        genreSection(user: user)
                        continueButton
                        
                        
                        Color.clear.frame(height: 40)
                    }
                    .padding()
                }
            } else {
                ProgressView("Loading Profile...")
                    .tint(.purple)
                    .foregroundStyle(Color.purple)
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
            
            if let user = viewModel.user, let url = user.profilePictureUrl {
                do {
//                    let data = try await StorageManager.shared.getData(userId: user.userId, url: url)
                    let data = try await StorageManager.shared.getData(from: url)
                    
                    if let uiImage = UIImage(data: data) {
                        self.profileImage = uiImage
                    }
                } catch {
                    print("Failed to load profile image: \(error)")
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignUpView: $showSignUpView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            if let newValue {
                // update image on screen
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.profileImage = uiImage
                    }
                }
                
                viewModel.saveProfileImage(item: newValue)
            }
        }
    }
}


// MARK: - Subviews
private extension ProfileView {
    
    // 1. Header Section (Image, Upload Button, Premium Status)
    func headerSection(user: DBUser) -> some View {
        VStack(spacing: 16) {
            
            // Profile Image & Picker
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    if let image = profileImage, image.size.width > 0 {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color.gray.opacity(0.5))
                    }
                }
                
                // Explicit Upload Button
                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                    Text("Upload Profile Photo")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.appWhite.opacity(0.1))
                        .foregroundColor(.appWhite)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.appWhite.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            Divider().background(Color.purple.opacity(0.3))
            
            // Name Display
            VStack(spacing: 4) {
                Text(viewModel.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                
                if let email = user.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            
            // Premium Button
            Button {
                viewModel.togglePremiumStatus()
            } label: {
                Text((user.isPremium ?? false) ? "Premium User" : "Upgrade to Premium")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.2))
                    .foregroundStyle(Color.purple) // Text color purple to pop
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(sectionBackgroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
    
    // 2. Name Input Section
    var nameInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Name")
                    .font(.headline)
                    .foregroundStyle(Color.purple) // Brighter header
                Spacer()
                Text("Required")
                    .font(.caption)
                    .foregroundStyle(Color.red.opacity(0.8))
            }
            
            if viewModel.firstName.isEmpty && viewModel.lastName.isEmpty {
                Text("Add your name so everyone knows it's you!")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                TextField("First Name", text: $viewModel.firstName)
                    .textContentType(.givenName)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(.black)
                
                TextField("Last Name", text: $viewModel.lastName)
                    .textContentType(.familyName)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(.black)
            }
            
            Button {
                viewModel.saveName()
            } label: {
                Text("Save Name")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .font(.headline)
            }
            .background(viewModel.firstName.trimmingCharacters(in: .whitespaces).isEmpty ||
                        viewModel.lastName.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color.gray.opacity(0.5)
                        : Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.firstName.trimmingCharacters(in: .whitespaces).isEmpty ||
                      viewModel.lastName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(sectionBackgroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
    
    // 3. Role Section
    var roleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("I am a...")
                    .font(.headline)
                    .foregroundStyle(Color.purple)
                
                Spacer()
                
                if let selected = viewModel.role {
                    Text(selected.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(Color.white)
                } else {
                    Text("Required")
                        .font(.caption)
                        .foregroundStyle(Color.red.opacity(0.8))
                }
            }
            
            HStack(spacing: 12) {
                ForEach(roleOptions, id: \.self) { role in
                    Button {
                        viewModel.updateUserRole(to: role)
                    } label: {
                        Text(role.rawValue.capitalized)
                            .font(.headline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(roleIsSelected(role) ? Color.purple : Color.white.opacity(0.1))
                            .foregroundStyle(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(roleIsSelected(role) ? Color.purple : Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding()
        .background(sectionBackgroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
    
    // 4. Genre Section
    func genreSection(user: DBUser) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Genres")
                .font(.headline)
                .foregroundColor(.purple)
            
            Text("Pick some quick genres or add your own.")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
            
            // Quick options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(genreOptions, id: \.self) { string in
                        Button(string) {
                            if genreIsSelected(text: string) {
                                viewModel.removeFavoriteGenre(text: string)
                            } else {
                                viewModel.addFavoriteGenre(text: string)
                            }
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(genreIsSelected(text: string) ? Color.purple : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                }
            }
            
            // Custom genre input
            HStack {
                TextField("Add a genre (e.g. House, R&B)", text: $viewModel.newGenre)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .foregroundColor(.black)
                
                Button {
                    viewModel.saveNewGenre()
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .disabled(viewModel.newGenre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            Text("Selected: \((user.genres ?? []).joined(separator: ", "))")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(sectionBackgroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
    
    // 5. Continue Button
    var continueButton: some View {
        VStack(spacing: 12) {
            Button {
                // Ensure the view isn't reloading during navigation
                if viewModel.isProfileComplete {
                    router.showScreen(.fullScreenCover) { _ in
                        HomeView(showSignUpView: $showSignUpView)
                    }
                }
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .background(viewModel.isProfileComplete ? Color.purple : Color.gray.opacity(0.3))
            .foregroundColor(viewModel.isProfileComplete ? .white : .white.opacity(0.5))
            .cornerRadius(14)
            .shadow(color: viewModel.isProfileComplete ? Color.purple.opacity(0.5) : Color.clear, radius: 10, x: 0, y: 5)
            .disabled(!viewModel.isProfileComplete)
            
            if !viewModel.isProfileComplete {
                Text("Complete your profile to continue.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    // MARK: - Helper Functions
    private func genreIsSelected(text: String) -> Bool {
        viewModel.user?.genres?.contains(text) == true
    }
    
    private func roleIsSelected(_ role: UserRole) -> Bool {
        viewModel.role == role
    }
}

#Preview {
    NavigationStack {
        RouterView { _ in
            ProfileView(showSignUpView: .constant(false))
        }
    }
}
