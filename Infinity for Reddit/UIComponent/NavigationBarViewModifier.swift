//
//  NavigationBarViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI

struct NavigationBarViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    var opacity: Double = 1
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .navigationBarTitleDisplayMode(.inline)
        } else {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color(hex: themeViewModel.currentCustomTheme.colorPrimary, opacity: opacity), for: .navigationBar)
        }
    }
}

struct InlineNavigationBarWithTitle: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    var title: String
    var opacity: Double

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .navigationBarPrimaryText()
                            .navigationBarTitleGlassEffect()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        } else {
            content
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .navigationBarPrimaryText()
                            .opacity(opacity)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NavigationBarTitleGlassEffectViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .glassEffect(.regular, in: Capsule())
        } else {
            content
        }
    }
}

struct NavigationBarButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content
                .tint(Color(hex: themeViewModel.currentCustomTheme.toolbarPrimaryTextAndIconColor))
        }
    }
}
