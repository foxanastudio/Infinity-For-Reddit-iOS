//
//  SpoilerFilledButton.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-17.
//

import SwiftUI

struct SpoilerFilledButton: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @Binding var isSpoiler: Bool
    
    var body: some View {
        Text("Spoiler")
            .customFilledButton(
                backgroundColor: isSpoiler ? Color(hex: customThemeViewModel.currentCustomTheme.spoilerBackgroundColor) : Color.clear,
                textColor: Color(hex: isSpoiler ? customThemeViewModel.currentCustomTheme.spoilerTextColor : customThemeViewModel.currentCustomTheme.primaryTextColor),
                borderColor: Color(hex: isSpoiler ? customThemeViewModel.currentCustomTheme.spoilerBackgroundColor : customThemeViewModel.currentCustomTheme.primaryTextColor)
            )
            .customFont(fontSize: .f12)
            .onTapGesture {
                isSpoiler.toggle()
            }
    }
}
