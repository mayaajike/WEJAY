//
//  PlaylistHeaderCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/30/25.
//

import SwiftUI
import SwiftfulUI

struct PlaylistHeaderCell: View {
    
    var height: CGFloat = 300
    var title: String = "Playlist Title"
    var subtitle: String = "Playlist subtitle"
    var imageName: String = Constants.randomImage
    var shadowColor: Color = .appBlack.opacity(0.8)
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .overlay(
                ImageLoaderView(urlString: imageName)
            )
            .overlay(
                VStack(alignment: .leading, spacing: 8) {
                    Text(subtitle)
                        .font(.headline)
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                    .foregroundStyle(.appWhite)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [shadowColor.opacity(0), shadowColor],
                            startPoint: .top, endPoint: .bottom)
                    )
                , alignment: .bottomLeading
            )
            .asStretchyHeader(startingHeight: height)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ScrollView {
            PlaylistHeaderCell()
        }
        .ignoresSafeArea()
    }
}
