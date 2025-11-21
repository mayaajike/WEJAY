//
//  AuthenticationView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit


struct AuthenticationView: View {
    
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignUpView: Bool
    
    var body: some View {
        VStack {
            
            // MARK: SIGN UP WITH EMAIL
            NavigationLink {
                SignUpEmailView(showSignUpView: $showSignUpView)
            } label: {
                Text("Sign Up With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            
            // MARK: SIGN IN WITH GOOGLE
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignUpView = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            // MARK: SIGN IN WITH APPLE
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        showSignUpView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                SignInWithAppleButtonViewRepresntable(type: .default, style: .black)
                    .allowsHitTesting(false)
            })
                .frame(height: 55)
            
            Divider()
                .frame(height: 1)
                .overlay(Color.purple)
                .padding(.vertical, 10)
            
            // MARK: LOOG IN WITH EMAIL
            NavigationLink {
                LogInEmailView(showSignUpView: $showSignUpView)
            } label: {
                Text("Log In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Welcome!")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignUpView: .constant(false))
    }
}

