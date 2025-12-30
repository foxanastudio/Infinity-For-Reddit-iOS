//
//  ButtonViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI

struct FilledButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.buttonTextColor))
            .tint(Color(hex: themeViewModel.currentCustomTheme.colorPrimaryLightTheme))
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
    }
}

struct SubscribeButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    let isSubscribed: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.buttonTextColor))
            .tint(Color(hex: isSubscribed ? themeViewModel.currentCustomTheme.subscribed : themeViewModel.currentCustomTheme.unsubscribed))
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
    }
}
