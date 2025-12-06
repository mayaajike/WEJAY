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
    @Published var firstName = ""
    @Published var lastName = ""
    
    @Published var formErrorMessage: String?
    
    func SignUp() async {
        formErrorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            formErrorMessage = "Please enter both email and password."
            return        }
        
        guard validateEmail(email) else {
            formErrorMessage = "Please enter a valid email address."
            return
        }
        
        guard validatePassword(password) else {
            return
        }
        
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let authDataResult = try await AuthenticationManager.shared.createUser(
                email: email,
                password: password,
                firstName: trimmedFirst.isEmpty ? nil : trimmedFirst,
                lastName: trimmedLast.isEmpty ? nil : trimmedLast
            )
            
            let user = DBUser(auth: authDataResult)
            try await UserManager.shared.createNewUser(user: user)
            
            formErrorMessage = nil
        } catch {
            formErrorMessage = error.localizedDescription
        }
    }
    
    // MARK: Email Validation
    private func validateEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: email)
    }
    
    // MARK: Password Validation
    private func validatePassword(_ password: String) -> Bool {
        formErrorMessage = nil
        
        guard password.count >= 8 else {
            formErrorMessage = "Password must be at least 8 characters long."
            return false
        }
        
        let uppercaseRange = password.rangeOfCharacter(from: .uppercaseLetters)
        guard uppercaseRange != nil else {
            formErrorMessage = "Password must contain at least one uppercase letter."
            return false
        }
        
        let digitRange = password.rangeOfCharacter(from: .decimalDigits)
        guard digitRange != nil else {
            formErrorMessage = "Password must contain at least one digit."
            return false
        }
        
        let specialCharacters = CharacterSet.alphanumerics.inverted
        let specialRange = password.rangeOfCharacter(from: specialCharacters)
        guard specialRange != nil else {
            formErrorMessage = "Password must contain at least one special character."
            return false
        }
        
        return true
    }
}
