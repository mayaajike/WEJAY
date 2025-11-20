//
//  LogInEmailView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI

@MainActor
final class LogInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func LogIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct LogInEmailView: View {
    
    @StateObject private var viewModel = LogInViewModel()
    @Binding var showSignUpView: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.purple
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white)
                
                VStack {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    Button {
                        // Authenticate the user
                        Task {
                            do {
                                try await viewModel.LogIn()
                                showSignUpView = false
                                return
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Log In With Email")
        }
    }
}

#Preview {
    NavigationStack {
        LogInEmailView(showSignUpView: .constant(false))
    }
}
