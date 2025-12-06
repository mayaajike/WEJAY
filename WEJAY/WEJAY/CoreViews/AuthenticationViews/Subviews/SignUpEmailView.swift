//
//  SignUpEmailView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI

struct SignUpEmailView: View {
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignUpView: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.purple
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.appBlack.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundColor(.appBlack.opacity(0.60))
                
                VStack(spacing: 14) {
                    TextField("First Name", text: $viewModel.firstName)
                        .padding()
                        .frame(width: 300, height: 60)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Last Name", text: $viewModel.lastName)
                        .padding()
                        .frame(width: 300, height: 60)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .frame(width: 300, height: 60)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .frame(width: 300, height: 60)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    Button {
                        // Authenticate the user
                        Task {
                            await viewModel.SignUp()
                            
                            if viewModel.formErrorMessage == nil {
                                showSignUpView = false
                            }
                        }
                    } label: {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 60)
                            .background(Color.purple)
                            .cornerRadius(10)
                    }

                    if let error = viewModel.formErrorMessage {
                        Text(error)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .frame(width: 300)
                            .padding(.top, 4)
                    }
                    
                    Spacer()
                        .frame(height: 16)
                    
                    NavigationLink(destination: LogInEmailView(showSignUpView: $showSignUpView)) {
                        Text("Have an account already? Log In")
                            .font(.body)
                            .foregroundColor(.purple)
                            .underline(color: .purple)
                    }
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Sign Up With Email")
        }
    }
}

#Preview {
    NavigationStack {
        SignUpEmailView(showSignUpView: .constant(false))
    }
}

