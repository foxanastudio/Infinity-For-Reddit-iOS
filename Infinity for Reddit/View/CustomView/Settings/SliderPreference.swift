//
//  SliderPreference.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-10.
//

import SwiftUI

struct SliderPreference: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    @Binding var value: Float
    let minValue: Float = 0
    let maxValue: Float
    let step: Float = 1
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    
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
            
            VStack(spacing: 4) {
                RowText(title)
                    .primaryText()
                
                if let subtitle = subtitle {
                    RowText(subtitle)
                        .secondaryText()
                }
                
                CustomUISlider(
                    value: $value,
                    in: minValue...maxValue,
                    step: step
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
