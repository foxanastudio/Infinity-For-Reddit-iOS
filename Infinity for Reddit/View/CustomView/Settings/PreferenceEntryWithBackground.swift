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
    let action: () -> Void
    
    private let largeRadius: CGFloat = 16
    private let smallRadius: CGFloat = 4
    
    let backgroundShape: RoundedCorner
    
    init(title: String, subtitle: String? = nil, icon: String? = nil, top: Bool = false, bottom: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.top = top
        if !top {
            self.bottom = bottom
        } else {
            self.bottom = false
        }
        self.backgroundShape = RoundedCorner(topLeft: top ? largeRadius : smallRadius, topRight: top ? largeRadius : smallRadius, bottomLeft: bottom ? largeRadius : smallRadius, bottomRight: bottom ? largeRadius : smallRadius)
        self.action = action
    }
    
    var body: some View {
        TouchRipple(backgroundShape: backgroundShape, action: action) {
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
            .clipShape(backgroundShape)
        }
        .padding(.top, top ? 16 : 2)
        .padding(.horizontal, 16)
    }
}
