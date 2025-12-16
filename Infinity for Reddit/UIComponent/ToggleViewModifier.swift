//
//  ToggleViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-02.
//

import SwiftUI

struct ToggleCustomThemeViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .toggleStyle(SwitchToggleStyle(tint: Color(hex: themeViewModel.currentCustomTheme.switchColor)))
    }
}
