//
//  PlaylistDescriptionCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/30/25.
//

import SwiftUI

struct PlaylistDescriptionCell: View {
    
    var descriptionText: String = Product.mock.description
    var userName: String = "Maya"
    var subHeadline: String = "Some headline goes here"
    var onAddToPlaylistPressed: (() -> Void)? = nil
    var onDownloadPressed: (() -> Void)? = nil
    var onSharePressed: (() -> Void)? = nil
    var onEllipsisPressed: (() -> Void)? = nil
    var onShufflePressed: (() -> Void)? = nil
    var onPlayPressed: (() -> Void)? = nil
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(descriptionText)
                .foregroundStyle(.appLightGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            madeForYouSection
            
            Text(subHeadline)
            
            buttonsRow
            
        }
        .font(.callout)
        .fontWeight(.medium)
        .foregroundStyle(.appLightGray)
    }
    
    private var madeForYouSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "apple.logo")
                .font(.title3)
                .foregroundStyle(.purple)
            
            (Text("Made for ")
             + Text(userName).bold())
                .foregroundStyle(.appWhite)

        }
    }
    
    private var buttonsRow: some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "plus.circle")
                    .padding(8)
                    .background(Color.black.opacity(0.001))
                    .onTapGesture {
                        
                    }
                
                Image(systemName: "arrow.down.circle")
                    .padding(8)
                    .background(Color.black.opacity(0.001))
                    .onTapGesture {
                        
                    }
                
                Image(systemName: "square.and.arrow.up")
                    .padding(8)
                    .background(Color.black.opacity(0.001))
                    .onTapGesture {
                        
                    }
                
                Image(systemName: "ellipsis")
                    .padding(8)
                    .background(Color.black.opacity(0.001))
                    .onTapGesture {
                        
                    }

            }
            .offset(x: -8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                Image(systemName: "shuffle")
                    .font(.system(size: 24))
                    .background(Color.black.opacity(0.001))
                    .onTapGesture {
                        
                    }
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 46))
                    .background(Color.black.opacity(0.001))
                    .onTapGesture {
                        
                    }
            }
            .foregroundStyle(.purple)
        }
        .font(.title2)
    }
}

#Preview {
    ZStack{
        Color.black.ignoresSafeArea()
        
        PlaylistDescriptionCell()
            .padding()
    }
}
