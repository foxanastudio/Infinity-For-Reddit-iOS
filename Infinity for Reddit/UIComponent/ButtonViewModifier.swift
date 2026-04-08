//
//  ButtonViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI

struct FilledButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    let elevate: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.buttonTextColor))
            .modify {
                if elevate {
                    $0.buttonStyle(FilledButtonStyle(color: Color(hex: themeViewModel.currentCustomTheme.colorPrimaryLightTheme)))
                } else {
                    $0.tint(Color(hex: themeViewModel.currentCustomTheme.colorPrimaryLightTheme))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                }
            }
    }
}

struct FilledButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .background(
                Capsule()
                    .fill(configuration.isPressed ? color.opacity(0.5) : color)
            )
            .clipped()
            .shadow(color: .gray.opacity(0.75), radius: 10, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
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
