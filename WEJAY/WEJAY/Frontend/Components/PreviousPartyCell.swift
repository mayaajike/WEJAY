//
//  PreviousPartyCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/30/25.
//

import SwiftUI

struct PreviousPartyCell: View {
    
    var imageSize: CGFloat = 100
    var imageName: String = Constants.randomImage
    var title: String = "Party Name"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ImageLoaderView(urlString: imageName)
                .frame(width: imageSize, height: imageSize)
            
            Text(title)
                .font(.callout)
                .foregroundStyle(.appLightGray)
                .lineLimit(2)
                .padding(4)
        }
        .frame(width: imageSize, alignment: .topLeading)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PreviousPartyCell()
    }
}
