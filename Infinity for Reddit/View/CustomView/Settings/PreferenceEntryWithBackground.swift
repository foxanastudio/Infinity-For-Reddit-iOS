//
//  PreferenceEntryWithBackground.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-17.
//

import SwiftUI

struct PreferenceEntryWithBackground: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let top: Bool
    let bottom: Bool
    let largeRadius: CGFloat = 16
    let smallRadius: CGFloat = 4
    
    init(title: String, subtitle: String? = nil, icon: String? = nil, top: Bool = false, bottom: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.top = top
        if !top {
            self.bottom = bottom
        } else {
            self.bottom = false
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if let icon = icon {
                SwiftUI.Image(systemName: icon)
                    .primaryIcon()
                    .frame(width: 24, height: 24, alignment: .leading)
                    .padding(0)
            } else {
                Spacer()
                    .frame(width: 24)
            }
            
            Spacer()
                .frame(width: 24)
            
            VStack(spacing: 0) {
                Text(title)
                    .primaryText()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let subtitle = subtitle {
                    Spacer()
                        .frame(height: 8)
                    
                    Text(subtitle)
                        .secondaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .filledCardBackground()
        .clipShape(RoundedCorner(topLeft: top ? largeRadius : smallRadius, topRight: top ? largeRadius : smallRadius, bottomLeft: bottom ? largeRadius : smallRadius, bottomRight: bottom ? largeRadius : smallRadius))
        .padding(.top, top ? 16 : 2)
        .padding(.horizontal, 16)
    }
}
