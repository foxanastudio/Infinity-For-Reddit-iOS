//
//  TabViewViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-23.
//

import SwiftUI

struct TabViewCustomThemeViewModifier: ViewModifier {
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .introspect(.tabView, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18, .v26)) { tabBarController in
                let appearance = UITabBarAppearance()
                
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color(hex: customThemeViewModel.currentCustomTheme.tabBarBackgroundColor))
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: customThemeViewModel.currentCustomTheme.tabBarTextAndIconColor))
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: customThemeViewModel.currentCustomTheme.colorPrimaryLightTheme))
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: customThemeViewModel.currentCustomTheme.tabBarTextAndIconColor))]
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: customThemeViewModel.currentCustomTheme.colorPrimaryLightTheme))]

                tabBarController.tabBar.standardAppearance = appearance
                tabBarController.tabBar.scrollEdgeAppearance = appearance
                tabBarController.view.backgroundColor = UIColor(Color(hex: customThemeViewModel.currentCustomTheme.tabBarBackgroundColor))
            }
    }
}
