//
//  SongRowCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/30/25.
//

import SwiftUI

struct SongRowCell: View {
    
    var imageSize: CGFloat = 50
    var imageName: String = Constants.randomImage
    var title: String = "Song name"
    var subtitle: String? = "Artist name"
    var onCellPressed: (() -> Void)? = nil
    var onEllipsisPressed: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 8) {
            ImageLoaderView(urlString: imageName)
                .frame(width: imageSize, height: imageSize)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.appWhite)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundStyle(.appLightGray)
                }
            }
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "ellipsis")
                .font(.subheadline)
                .foregroundStyle(.appWhite)
                .padding(16)
                .background(Color.black.opacity(0.001))
                .onTapGesture {
                    onEllipsisPressed?()
                }
        }
        .background(Color.black.opacity(0.001))
        .onTapGesture {
            onCellPressed?()
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            SongRowCell()
            SongRowCell()
            SongRowCell()
            SongRowCell()
        }
    }
}
