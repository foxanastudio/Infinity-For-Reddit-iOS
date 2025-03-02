//
// ThemeSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct CustomThemeSettingsView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @StateObject private var customThemeSettingsViewModel = CustomThemeSettingsViewModel()
    @StateObject private var customThemeViewModel: CustomThemeViewModel
    
    init() {
        _customThemeViewModel = StateObject(
            wrappedValue: CustomThemeViewModel()
        )
    }
    
    var body: some View {
        List {
            Picker("Theme", systemImage: "paintbrush.fill", selection: $customThemeSettingsViewModel.theme) {
                ForEach(0..<customThemeSettingsViewModel.themeOptions.count, id: \.self) { index in
                    Text(customThemeSettingsViewModel.themeOptions[index]).tag(index)
                }
            }
            .themedPicker()
            .listPlainItem()
            
            Toggle("AMOLED Dark", systemImage: "moon.fill", isOn: $customThemeSettingsViewModel.amoledDark)
                .themedToggle()
                .listPlainItem()

            Section(header: Text("Customization")) {
                CustomNavigationLink(destination: CustomizeCustomThemeView(customTheme: customThemeViewModel.currentLightCustomTheme ?? CustomTheme.getIndigo())) {
                    themeListItem(
                        themeType: "Light Theme",
                        themeName: customThemeViewModel.currentLightCustomTheme?.name ?? "Indigo",
                        icon: "upvoted")
                }
                CustomNavigationLink(destination: CustomizeCustomThemeView(customTheme: customThemeViewModel.currentLightCustomTheme ?? CustomTheme.getIndigo())) {
                    themeListItem(
                        themeType: "Light Theme",
                        themeName: customThemeViewModel.currentLightCustomTheme?.name ?? "Indigo",
                        icon: "upvoted")
                }
                
                CustomNavigationLink(destination: CustomizeCustomThemeView(customTheme: customThemeViewModel.currentDarkCustomTheme ?? CustomTheme.getIndigoDark())) {
                    themeListItem(
                        themeType: "Dark Theme",
                        themeName: customThemeViewModel.currentDarkCustomTheme?.name ?? "Indigo Dark",
                        icon: "upvoted")
                }
                
                CustomNavigationLink(destination: CustomizeCustomThemeView(customTheme: customThemeViewModel.currentAmoledCustomTheme ?? CustomTheme.getIndigoAmoled())) {
                    themeListItem(
                        themeType: "Amoled Theme",
                        themeName: customThemeViewModel.currentAmoledCustomTheme?.name ?? "Indigo Amoled",
                        icon: "upvoted")
                }
                
                CustomNavigationLink(destination: CustomThemeListingView()) {
                    HStack {
                        SwiftUI.Image("upvote")
                        
                        Spacer()
                            .frame(width: 16)
                        
                        Text("Manage Themes")
                    }
                }
            }
            .listPlainItem()
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Theme")
    }
    
    func themeListItem(themeType: String, themeName: String, icon: String) -> some View {
        HStack {
            SwiftUI.Image(icon)
            
            Spacer()
                .frame(width: 16)
            
            VStack(alignment: .leading) {
                Text(themeType)
                
                Spacer()
                    .frame(height: 8)
                
                Text(themeName)
            }
        }
    }
}
