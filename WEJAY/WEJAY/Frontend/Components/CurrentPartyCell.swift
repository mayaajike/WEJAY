//
//  RecentPartyCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/26/25.
//

import SwiftUI

struct CurrentPartyCell: View {
    
    var imageName: String = Constants.randomImage
    var headline: String? = "Most recent playlist"
    var subheadline: String? = "Some Party"
    var title: String? = "Some DJ"
    var subtitle: String? = "Single - title"
    var onAddToPlaylistPressed: (() -> Void)? = nil
    var onPlayPressed: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                ImageLoaderView(urlString: imageName)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    if let headline {
                        Text(headline)
                            .foregroundStyle(.appLightGray)
                            .font(.callout)
                    }
                    
                    if let subheadline {
                        Text(subheadline.capitalized)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.appWhite)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ImageLoaderView(urlString: imageName)
                    .frame(width: 140, height: 140)
                
                VStack(alignment: .leading, spacing: 32){
                    VStack(alignment: .leading, spacing: 2) {
                        if let title {
                            Text(title)
                                .fontWeight(.semibold)
                                .foregroundStyle(.appWhite)
                        }
                        
                        if let subtitle {
                            Text(subtitle)
                                .foregroundStyle(.appLightGray)
                                .lineLimit(5)
                        }
                    }
                    .font(.callout)
                    
                    HStack(spacing: 0) {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.appLightGray)
                            .font(.title3)
                            .padding(4)
                            .background(Color.black.opacity(0.001))
                            .onTapGesture {
                                onAddToPlaylistPressed?()
                            }
                            .offset(x: -4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "play.circle.fill")
                            .foregroundStyle(.appWhite)
                            .font(.title)
                    }
                }
                .padding(.trailing, 16)
            }
            .padding()
            .themeColors(isSelected: false)
            .cornerRadius(8)
            .onTapGesture {
                onPlayPressed?()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CurrentPartyCell()
            .padding()
    }
}
