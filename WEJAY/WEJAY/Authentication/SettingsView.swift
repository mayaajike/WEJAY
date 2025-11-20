//
//  SettingsView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    enum AuthError: LocalizedError {
        case missingEmail
        
        var errorDescription: String? {
            switch self {
            case .missingEmail:
                return "No email associated with this session. Sign in again"
            }
        }
    }
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw AuthError.missingEmail
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updatePassword(newPassword: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: newPassword)
    }
    
    func updateEmail() async throws {
        try await AuthenticationManager.shared.updateEmail()
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignUpView: Bool
    @State private var showResetAlert = false
    @State private var showUpdateEmailAlert = false
    @State private var showPasswordField = false
    @State private var newPassword = ""
    @State private var showPasswordUpdateAlert = false
    @State private var showReAuthAlert = false
    @State private var showLogInView = false
    
    var body: some View {
        List {
            // Log out button
            Button("Log Out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignUpView = true
                    } catch {
                        print(error)
                    }
                }
            }
            if viewModel.authProviders.contains(.email) {
                // update email & update & reset password buttons
                emailSection
            }
            
            }
            .alert("Password Updated Successfully", isPresented: $showPasswordUpdateAlert) {
                Button ("Ok", role: .cancel) {}
            }
            .alert("Log in again to complete this action.", isPresented: $showReAuthAlert) {
                Button("Log In") { showLogInView = true }
                Button ("Cancel", role: .cancel) {}
            }
            .onAppear {
                viewModel.loadAuthProviders()
            }
        .navigationBarTitle("Settings")
        .navigationDestination(isPresented: $showLogInView) {
            LogInEmailView(showSignUpView: $showLogInView)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignUpView: .constant(false))
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            // reset password button
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        showResetAlert = true
                    } catch {
                        print(error)
                    }
                }
            }
            .alert("Password Reset Link Sent", isPresented: $showResetAlert) {
                Button ("Ok", role: .cancel) {}
            }
            
            // update email button
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        showUpdateEmailAlert = true
                    } catch {
                        // Convert to NSError
                        let nsError = error as NSError
                        
                        // Get numeric code
                        let ErrorCode = nsError.code
                        if ErrorCode == 17014 {
                            showReAuthAlert = true
                        }
                        else {
                            print(error)
                        }
                    }
                }
            }
            .alert("Email Update Link Sent", isPresented: $showUpdateEmailAlert) {
                Button ("Ok", role: .cancel) {}
            }
            .alert("Log in again to complete this action.", isPresented: $showReAuthAlert) {
                Button("Log In") { showLogInView = true }
                Button ("Cancel", role: .cancel) {}
            }
            
            // update password button
            Button("Update Password") {
                withAnimation { showPasswordField.toggle() }
            }
            
            if showPasswordField {
                SecureField ("Enter new password", text: $newPassword)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                
                Button("Submit") {
                    Task {
                        do {
                            try await viewModel.updatePassword(newPassword: newPassword)
                            withAnimation { showPasswordField = false }
                            newPassword = ""
                            showPasswordUpdateAlert = true
                        } catch {
                            // Convert to NSError
                            let nsError = error as NSError
                                
                            // Get numeric code
                            let ErrorCode = nsError.code
                            if ErrorCode == 17014 {
                                showReAuthAlert = true
                            }
                            else {
                                print(error)
                            }
                        }
                    }
                }
                .disabled(newPassword.isEmpty)
                }
        } header : {
            Text("Email Functions")
        }
    }
}

