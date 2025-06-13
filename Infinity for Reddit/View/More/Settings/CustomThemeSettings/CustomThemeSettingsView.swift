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
    @EnvironmentObject private var navigationManager: NavigationManager
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
                themeListItem(
                    themeType: "Light Theme",
                    themeName: customThemeViewModel.currentLightCustomTheme?.name ?? "Indigo",
                    icon: "upvoted")
                .onTapGesture {
                    navigationManager.path.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customTheme: customThemeViewModel.currentLightCustomTheme ?? CustomTheme.getIndigo()))
                }
                
                themeListItem(
                    themeType: "Dark Theme",
                    themeName: customThemeViewModel.currentDarkCustomTheme?.name ?? "Indigo Dark",
                    icon: "upvoted")
                .onTapGesture {
                    navigationManager.path.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customTheme: customThemeViewModel.currentDarkCustomTheme ?? CustomTheme.getIndigoDark()))
                }
                
                themeListItem(
                    themeType: "Amoled Theme",
                    themeName: customThemeViewModel.currentAmoledCustomTheme?.name ?? "Indigo Amoled",
                    icon: "upvoted")
                .onTapGesture {
                    navigationManager.path.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customTheme: customThemeViewModel.currentAmoledCustomTheme ?? CustomTheme.getIndigoAmoled()))
                }
                
                HStack {
                    SwiftUI.Image("upvote")
                    
                    Spacer()
                        .frame(width: 16)
                    
                    Text("Manage Themes")
                }
                .onTapGesture {
                    navigationManager.path.append(CustomThemeSettingsViewNavigation.customThemeListing)
                }
            }
            .listPlainItem()
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Theme", 1.0)
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
