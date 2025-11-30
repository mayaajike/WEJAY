//
//  RootView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI

struct RootView: View {
    @State private var showSignUpView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignUpView {
                NavigationStack {
                    ProfileView(showSignUpView: $showSignUpView)
                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignUpView = authUser == nil

        }
        .fullScreenCover(isPresented: $showSignUpView) {
            NavigationStack {
                AuthenticationView(showSignUpView: $showSignUpView)
            }
        }
    }
}

#Preview {
    RootView()
}
