//
//  CustomThemeListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-20.
//

import SwiftUI
import Swinject
import GRDB

struct CustomThemeListingView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject private var customThemeListingViewModel = CustomThemeListingViewModel()
    
    init() {
        _customThemeListingViewModel = StateObject(
            wrappedValue: CustomThemeListingViewModel()
        )
    }
    
    var body: some View {
        List {
            ForEach(customThemeListingViewModel.customThemes, id: \.self.id) { customTheme in
                NavigationLink(destination: CustomizeCustomThemeView(customTheme: customTheme)) {
                    ThemeListItem(themeName: customTheme.name, primaryColor: Color(hex: customTheme.colorPrimary))
                }
            }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Custom Themes", 1.0)
    }
    
    func ThemeListItem(themeName: String, primaryColor: Color) -> some View {
        HStack {
            Circle()
                .fill(primaryColor)
                .frame(width: 24, height: 24)
            
            Spacer()
                .frame(width: 16)
            
            Text(themeName)
        }
    }
}
