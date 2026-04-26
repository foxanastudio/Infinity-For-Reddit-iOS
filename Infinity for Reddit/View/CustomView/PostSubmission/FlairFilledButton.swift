//
//  FlairFilledButton.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-17.
//

import SwiftUI

struct FlairFilledButton: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    var selectedFlair: Flair?
    let onTap: () -> Void
    
    var isSelected: Bool {
        selectedFlair != nil
    }
    
    var body: some View {
        Text(selectedFlair?.text ?? "Flair")
            .customFilledButton(
                backgroundColor: isSelected ? Color(hex: customThemeViewModel.currentCustomTheme.flairBackgroundColor) : Color.clear,
                textColor: Color(hex: isSelected ? customThemeViewModel.currentCustomTheme.flairTextColor : customThemeViewModel.currentCustomTheme.primaryTextColor),
                borderColor: Color(hex: isSelected ? customThemeViewModel.currentCustomTheme.flairBackgroundColor : customThemeViewModel.currentCustomTheme.primaryTextColor)
            )
            .customFont(fontSize: .f12)
            .onTapGesture {
                onTap()
            }
    }
}
