//
//  GuideBarCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/26/25.
//

import SwiftUI

struct GuideBarCell: View {
    
    var imageName: String = Constants.randomImage
    var title: String = "Some random title"
    
    var body: some View {
        HStack(spacing: 16) {
            ImageLoaderView(urlString: imageName)
                .frame(width: 55, height: 55)
            
            Text(title)
                .font(.callout)
                .fontWeight(.semibold)
                .lineLimit(2)
        }
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .themeColors(isSelected: false)
        .cornerRadius(6)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            HStack {
                GuideBarCell()
                GuideBarCell()
            }
            
            HStack {
                GuideBarCell()
                GuideBarCell()
            }
        }
    }
}
