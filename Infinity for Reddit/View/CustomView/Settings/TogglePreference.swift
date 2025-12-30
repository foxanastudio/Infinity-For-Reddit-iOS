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
                    
                    Spacer()
                        .frame(width: 16)
                }
                
                VStack(spacing: 4) {
                    RowText(title)
                        .primaryText()
                    
                    if let subtitle {
                        RowText(subtitle)
                            .secondaryText()
                    }
                }
                .padding(.vertical, 16)
                .padding(.trailing, 16)
                
                Toggle("", isOn: $isEnabled)
                    .themedToggle()
                    .labelsHidden()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
        }
        .limitedWidthListItem()
    }
}
