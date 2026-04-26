//
//  SensitiveFilledButton.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-17.
//

import SwiftUI

struct SensitiveFilledButton: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @Binding var isSensitive: Bool
    
    var body: some View {
        Text("Sensitive")
            .customFilledButton(
                backgroundColor: isSensitive ? Color(hex: customThemeViewModel.currentCustomTheme.nsfwBackgroundColor) : Color.clear,
                textColor: Color(hex: isSensitive ? customThemeViewModel.currentCustomTheme.nsfwTextColor : customThemeViewModel.currentCustomTheme.primaryTextColor),
                borderColor: Color(hex: isSensitive ? customThemeViewModel.currentCustomTheme.nsfwBackgroundColor : customThemeViewModel.currentCustomTheme.primaryTextColor)
            )
            .customFont(fontSize: .f12)
            .onTapGesture {
                isSensitive.toggle()
            }
    }
}
