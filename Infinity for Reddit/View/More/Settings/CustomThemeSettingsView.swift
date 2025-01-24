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
    @StateObject private var customThemeSettingsViewModel = CustomThemeSettingsViewModel()
    
    var body: some View {
        Form {
            Section {
                Picker("Theme", systemImage: "paintbrush.fill", selection: $customThemeSettingsViewModel.theme) {
                    ForEach(0..<customThemeSettingsViewModel.themeOptions.count, id: \.self) { index in
                        Text(customThemeSettingsViewModel.themeOptions[index]).tag(index)
                    }
                }
                
                Toggle("Enable AMOLED Dark Mode", systemImage: "moon.fill", isOn: $customThemeSettingsViewModel.amoledDark)
            }
        }
        .navigationTitle("Theme")
    }
}
