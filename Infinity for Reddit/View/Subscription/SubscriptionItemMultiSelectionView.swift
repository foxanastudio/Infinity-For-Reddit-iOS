//
//  SubscriptionItemMultiSelectionView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import SwiftUI

struct SubscriptionItemMultiSelectionView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    var text: String
    var iconUrl: String?
    var iconSize: CGFloat = 24
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        TouchRipple {
            HStack(spacing: 0) {
                if let icon = iconUrl {
                    CustomWebImage(
                        icon,
                        width: iconSize,
                        height: iconSize,
                        circleClipped: true,
                        handleImageTapGesture: false,
                        fallbackView: {
                            InitialLetterAvatarImageFallbackView(name: text, size: iconSize)
                        }
                    )
                } else {
                    Spacer()
                        .frame(width: iconSize)
                }
                
                Spacer()
                    .frame(width: 24)
                
                Text(text)
                    .primaryText()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 16)
                
                SwiftUI.Image(systemName: isSelected ? "checkmark.square" : "square")
                    .primaryIcon()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(isSelected ? Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
        }
    }
}
