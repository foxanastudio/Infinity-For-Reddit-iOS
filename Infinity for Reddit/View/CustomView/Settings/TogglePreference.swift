//
//  TogglePreference.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-16.
//

import SwiftUI

struct TogglePreference: View {
    @Binding var isEnabled: Bool
    
    let title: String
    let subtitle: String?
    let icon: String?
    
    init(isEnabled: Binding<Bool>, title: String, subtitle: String? = nil, icon: String? = nil) {
        self._isEnabled = isEnabled
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
    
    var body: some View {
        TouchRipple(action: {
            isEnabled.toggle()
        }) {
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
                
                VStack {
                    RowText(title)
                        .primaryText()
                    
                    if let subtitle = subtitle {
                        RowText(subtitle)
                            .secondaryText()
                    }
                }
                .frame(maxWidth: .infinity)
                
                Toggle(isOn: $isEnabled) {}
                    .themedToggle()
                    .excludeFromTouchRipple()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
