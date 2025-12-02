//
//  GuideBarCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/26/25.
//

import SwiftUI

enum GuideBarOption {
    case spotify
    case appleMusic
    case share
    
    var title: String {
        switch self {
        case .spotify: return "Sign in to Spotify"
        case .appleMusic: return "Sign in to Apple Music"
        case .share: return "Share party"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .spotify: return Color.appGreen
        case .appleMusic: return Color.red
        case .share: return Color.purple
        }
    }
    
    var icon: Image {
        switch self {
        case .spotify: return Image(.spotifyIcon)
        case .appleMusic: return Image(systemName: "apple.logo")
        case .share: return Image(systemName: "square.and.arrow.up.fill")
        }
    }
    
    var isCentered: Bool {
        self == .share
    }
}


struct GuideBarCell: View {
    let option: GuideBarOption
    let titleOverride: String?
    let action: () -> Void
    
    private var titleText: String {
        titleOverride ?? option.title
    }
    
    var body: some View {
        Button(action: action) {
            content
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(option.backgroundColor)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var content: some View {
        if option.isCentered {
            // Centered icon + text (Share)
            HStack(spacing: 8) {
                Spacer()
                
                option.icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                Text(titleText)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Spacer()
            }
        } else {
            // Left-aligned (Spotify / Apple Music)
            HStack(spacing: 16) {
                option.icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(6)
                    .background(Color.black.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(titleText)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GuideBarCell(option: .spotify, titleOverride: nil) { }
                GuideBarCell(option: .appleMusic, titleOverride: nil) { }
            }
            
            GuideBarCell(option: .share, titleOverride: nil) { }
        }
        .padding()
    }
}

