//
//  PreferenceEntry.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-03.
//

import SwiftUI

struct PreferenceEntry: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var onClick: () -> Void
    
    var body: some View {
        TouchRipple(action: onClick) {
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
                
                VStack(spacing: 4) {
                    RowText(title)
                        .primaryText()
                    
                    if let subtitle = subtitle {
                        RowText(subtitle)
                            .secondaryText()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, subtitle == nil ? 16 : 8)
        }
    }
}
