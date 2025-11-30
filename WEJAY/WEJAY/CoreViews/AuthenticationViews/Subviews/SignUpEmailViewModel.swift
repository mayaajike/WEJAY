//
//  SignUpEmailViewModel.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import Foundation

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func SignUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }

        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        
        try await UserManager.shared.createNewUser(user: user)
    }
}
