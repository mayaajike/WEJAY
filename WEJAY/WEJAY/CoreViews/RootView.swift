//
//  RootView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/20/25.
//

import SwiftUI

private enum RootDestination {
    case loading
    case profile
    case djHome
    case guestHome
}

struct RootView: View {
    @State private var showSignUpView: Bool = false
    @State private var destination: RootDestination = .loading
    
    var body: some View {
        ZStack {
            switch destination {
            case .loading:
                ProgressView("Loading...")
                    .tint(.purple)
                    .foregroundStyle(.purple)
                
            case .profile:
                ProfileView(showSignUpView: $showSignUpView)
            case .djHome:
                DJHomeView(showSignUpView: $showSignUpView)
            case .guestHome:
                GuestHomeView(showSignUpView: $showSignUpView)
            }
        }
        .task {
            await configureInitialScreen()
        }
        .onChange(of: showSignUpView) { _, isShowing in
            // When auth sheet is dismissed (login / signup success),
            // re-evaluate where the user should go.
            if !isShowing {
                Task {
                    await configureInitialScreen()
                }
            }
        }
        .fullScreenCover(isPresented: $showSignUpView) {
            NavigationStack {
                AuthenticationView(showSignUpView: $showSignUpView)
            }
        }
    }
    
    // MARK: - Routing Helpers
    
    private func configureInitialScreen() async {
        if let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() {
            await setDestinationForAuthenticatedUser(userId: authUser.uid)
        } else {
            await MainActor.run {
                showSignUpView = true
                destination = .loading
            }
        }
    }
    
    private func setDestinationForAuthenticatedUser(userId: String) async {
        do {
            let dbUser = try await UserManager.shared.getUser(userId: userId)
            
            await MainActor.run {
                showSignUpView = false

                if dbUser.isProfileComplete {
                    if dbUser.role == .dj {
                        destination = .djHome
                    } else {
                        destination = .guestHome
                    }
                } else {
                    // If incomplete profile (!fullName || !role), force them to ProfileView
                    destination = .profile
                }
            }
        } catch {
            print("Error fetching DBUser in RootView: \(error)")
            await MainActor.run {
                showSignUpView = false
                destination = .profile
            }
        }
    }
}

#Preview {
    RootView()
}



//        ZStack {
//            if !showSignUpView {
//                NavigationStack {
//                    ProfileView(showSignUpView: $showSignUpView)
//                }
//            }
//        }
//        .onAppear {
//            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
//            self.showSignUpView = authUser == nil
//
//        }
//        .fullScreenCover(isPresented: $showSignUpView) {
//            NavigationStack {
//                AuthenticationView(showSignUpView: $showSignUpView)
//            }
//        }
//    }
//}
