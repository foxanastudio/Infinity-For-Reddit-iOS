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
                    title: "AMOLED Dark",
                    icon: "moon.fill"
                )
                .listPlainItemNoInsets()

                CustomListSection("Customization") {
                    PreferenceEntry(
                        title: "Light Theme",
                        subtitle: customThemeViewModel.currentLightCustomTheme?.name ?? "Indigo",
                        icon: "sun.max"
                    ) {
                        navigationManager.path.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customTheme: customThemeViewModel.currentLightCustomTheme ?? CustomTheme.getIndigo()))
                    }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(
                        title: "Dark Theme",
                        subtitle: customThemeViewModel.currentDarkCustomTheme?.name ?? "Indigo Dark",
                        icon: "moon"
                    ) {
                        navigationManager.path.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customTheme: customThemeViewModel.currentDarkCustomTheme ?? CustomTheme.getIndigoDark()))
                    }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(
                        title: "Amoled Theme",
                        subtitle: customThemeViewModel.currentAmoledCustomTheme?.name ?? "Indigo Amoled",
                        icon: "moon"
                    ) {
                        navigationManager.path.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customTheme: customThemeViewModel.currentAmoledCustomTheme ?? CustomTheme.getIndigoAmoled()))
                    }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(
                        title: "Manage Themes",
                        icon: "pencil"
                    ) {
                        navigationManager.path.append(CustomThemeSettingsViewNavigation.customThemeListing)
                    }
                    .listPlainItemNoInsets()
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Theme")
        .onChange(of: theme) { oldValue, newValue in
            customThemeViewModel.setThemeType(newValue)
        }
        .onChange(of: amoledDark) { oldValue, newValue in
            customThemeViewModel.setAmoledDark(newValue)
        }
    }
}
