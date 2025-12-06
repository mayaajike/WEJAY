//
//  LogInEmailView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI

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
                    .foregroundColor(.appBlack.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundColor(.appBlack.opacity(0.60))
                
                VStack {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.appWhite)
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                    
                    Button {
                        // Authenticate the user
                        Task {
                            await viewModel.LogIn()
                            
                            if viewModel.formErrorMessage == nil {
                                showSignUpView = false
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
                    
                    if let error = viewModel.formErrorMessage {
                        Text(error)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.red)
                            .multilineTextAlignment(.center)
                            .frame(width: 300)
                            .padding(.top, 4)
                    }
                    
                    Spacer()
                        .frame(height: 16)
                    
                    NavigationLink(destination: SignUpEmailView(showSignUpView: $showSignUpView)) {
                        Text("Don't have an account yet? Sign Up")
                            .font(.body)
                            .foregroundColor(.purple)
                            .underline(color: .purple)
                    }
                    .padding(.top , 4)
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
