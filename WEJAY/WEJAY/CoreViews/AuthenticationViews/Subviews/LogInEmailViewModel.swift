//
//  LogInEmailViewModel.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import Foundation

@MainActor
final class LogInViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func LogIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
//        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
