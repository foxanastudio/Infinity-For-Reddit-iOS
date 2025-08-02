//
//  InfoPreference.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-01.
//

import SwiftUI

struct InfoPreference: View {
    var title: String
    var iconUrl: String? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            if let iconUrl = iconUrl {
                SwiftUI.Image(systemName: iconUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .secondaryIcon()
                
                Spacer()
                    .frame(width: 32)
            } else {
                Spacer()
                    .frame(width: 56)
            }
            
            Text(title)
                .secondaryText()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
    }
}
