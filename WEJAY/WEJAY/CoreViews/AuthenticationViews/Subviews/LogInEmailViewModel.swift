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
    @Published var formErrorMessage: String?
    
    func LogIn() async {
        formErrorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            formErrorMessage = "Please fill in both fields."
            return
        }
        
        guard validateEmail(trimmedEmail) else {
            formErrorMessage = "Please enter a valid email address."
            return
        }
        
        do {
            _ = try await AuthenticationManager.shared.signInUser(email: trimmedEmail, password: password)
            
            formErrorMessage = nil
        } catch {
            formErrorMessage = error.localizedDescription
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: email)
    }
}
