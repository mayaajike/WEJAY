//
//  NavScrollBarCell.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 11/25/25.
//

import SwiftUI

struct NavScrollBarCell: View {
    
    var message: String = "Message Here"
    var isSelected: Bool = false
    
    var body: some View {
        Text(message)
            .font(.callout)
            .frame(minWidth: 40, minHeight: 35)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .themeColors(isSelected: isSelected)
            .cornerRadius(23)
    }
}

extension View {
    
    func themeColors(isSelected: Bool) -> some View {
        self
            .background(isSelected ? .purple : .appDarkGray)
            .foregroundStyle(isSelected ? .appBlack : .appWhite)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            NavScrollBarCell(message: "Message goes here")
            NavScrollBarCell(message: "Message goes here", isSelected: true)
            NavScrollBarCell(message: "Message goes here")
            NavScrollBarCell(message: "Message goes here", isSelected: true)
        }
        
        NavScrollBarCell()
    }
}
