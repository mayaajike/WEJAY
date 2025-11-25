//
//  AuthenticationViewModel.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    
    let signInAppleHelper = SignInAppleHelper()
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signInApple() async throws{
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        // let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
//        let user = DBUser(auth: authDataResult)
//        
//        try await UserManager.shared.createNewUser(user: user)
    }
}
