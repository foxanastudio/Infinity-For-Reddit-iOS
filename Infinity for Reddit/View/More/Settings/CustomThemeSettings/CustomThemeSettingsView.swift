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
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @AppStorage(CustomThemeUserDefaultsUtils.themeKey, store: .theme) private var theme: Int = CustomThemeUserDefaultsUtils.themeDeviceDefault
    @AppStorage(CustomThemeUserDefaultsUtils.amoledDarkKey, store: .theme) private var amoledDark: Bool = false
    
    @State private var showCreateThemeSheet: Bool = false
    
    var body: some View {
        RootView {
            List {
                PickerPreference(
                    selectedIndex: $theme,
                    items: CustomThemeUserDefaultsUtils.themeOptions,
                    title: "Theme",
                    icon: "paintbrush.fill"
                )
                .listPlainItemNoInsets()
                
                TogglePreference(
                    isEnabled: $amoledDark,
                    title: "Amoled Dark",
                    icon: "moon.fill"
                )
                .listPlainItemNoInsets()

                CustomListSection("Customization") {
                    PreferenceEntry(
                        title: "Light Theme",
                        subtitle: customThemeViewModel.currentLightCustomTheme?.name ?? "Indigo",
                        icon: "sun.max"
                    ) {
                        navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customThemeId: customThemeViewModel.currentLightCustomTheme?.id, predefindCustomThemeName: "Indigo"))
                    }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(
                        title: "Dark Theme",
                        subtitle: customThemeViewModel.currentDarkCustomTheme?.name ?? "Indigo Dark",
                        icon: "moon"
                    ) {
                        navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customThemeId: customThemeViewModel.currentDarkCustomTheme?.id, predefindCustomThemeName: "Indigo Dark"))
                    }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(
                        title: "Amoled Theme",
                        subtitle: customThemeViewModel.currentAmoledCustomTheme?.name ?? "Indigo Amoled",
                        icon: "moon"
                    ) {
                        navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customThemeId: customThemeViewModel.currentAmoledCustomTheme?.id, predefindCustomThemeName: "Indigo Amoled"))
                    }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(
                        title: "Manage Themes",
                        icon: "pencil"
                    ) {
                        navigationManager.append(CustomThemeSettingsViewNavigation.customThemeListing)
                    }
                    .listPlainItemNoInsets()
                }
                
                CustomListSection("Predefined Themes") {
                    ForEach(CustomTheme.predefinedCustomThemes, id: \.self.name) { customTheme in
                        ThemeListItem(themeName: customTheme.name, primaryColor: Color(hex: customTheme.colorPrimary)) {
                            navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(predefindCustomThemeName: customTheme.name))
                        }
                        .listPlainItemNoInsets()
                    }
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Theme")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showCreateThemeSheet = true
                } label: {
                    SwiftUI.Image(systemName: "plus")
                }
            }
        }
        .onChange(of: theme) { oldValue, newValue in
            customThemeViewModel.setThemeType(newValue)
        }
        .onChange(of: amoledDark) { oldValue, newValue in
            customThemeViewModel.setAmoledDark(newValue)
        }
        .wrapContentSheet(isPresented: $showCreateThemeSheet) {
            CreateThemeSheet(onCreateLightTheme: {
                navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customThemeId: customThemeViewModel.currentLightCustomTheme?.id, predefindCustomThemeName: "Indigo"))
            }, onCreateDarkTheme: {
                navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customThemeId: customThemeViewModel.currentDarkCustomTheme?.id, predefindCustomThemeName: "Indigo Dark"))
            }, onCreateAmoledTheme: {
                navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customThemeId: customThemeViewModel.currentAmoledCustomTheme?.id, predefindCustomThemeName: "Indigo Amoled"))
            }, onImportTheme: {
                
            })
        }
    }
}
