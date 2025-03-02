//
//  PickerViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-02.
//

import SwiftUI

struct PickerCustomThemeViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .tint(Color(hex: themeViewModel.currentCustomTheme.secondaryTextColor))
    }
}
