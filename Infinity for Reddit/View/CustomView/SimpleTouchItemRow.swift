//
//  SimpleTouchItemRow.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-18.
//

import SwiftUI

struct SimpleTouchItemRow: View {
    var text: String
    var icon: String?
    var action: (() -> Void)?
    
    var body: some View {
        TouchRipple(action: {
            action?()
        }) {
            HStack(spacing: 0) {
                if let icon = icon {
                    SwiftUI.Image(systemName: icon)
                        .primaryIcon()
                        .frame(width: 24, height: 24, alignment: .leading)
                        .padding(0)
                } else {
                    Spacer().frame(width: 24)
                }
                
                Spacer().frame(width: 24)
                
                Text(text)
                    .primaryText()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
    }
}
