//
//  SettingsView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI
import SwiftfulRouting

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignUpView: Bool
    @Environment(\.router) var router
    
    @State private var showResetAlert = false
    @State private var showUpdateEmailAlert = false
    @State private var showPasswordField = false
    @State private var newPassword = ""
    @State private var showPasswordUpdateAlert = false
    @State private var showReAuthAlert = false
    @State private var showLogInView = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        List {
            // Log out button
            Button("Log Out") {
                Task {
                    do {
                        try viewModel.signOut()
                        
                        await MainActor.run {
                            showSignUpView = true
                             router.dismissAllScreens()
                        }
                        
                    } catch {
                        print(error)
                    }
                }
            }
            
            // Delete account button
            Button(role: .destructive) {
                // Just show the alert first
                showDeleteAlert = true
            } label: {
                Text("Delete Account")
            }
            .alert("Delete Account",
                   isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    Task {
                        do {
                            try await viewModel.deleteAccount()
                            showSignUpView = true
                        } catch {
                            print(error)
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete your account? This action is permanent and cannot be undone.")
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

