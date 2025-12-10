//
// GestureButtonsSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct GestureButtonsSettingsView: View {
    @AppStorage(GesturesButtonsUserDefaultsUtils.hideNavigationBarOnScrollDownKey, store: .gesturesButtons) private var hideNavigationBarOnScrollDown: Bool = false
    
    var body: some View {
        RootView {
            List {
                TogglePreference(
                    isEnabled: $hideNavigationBarOnScrollDown,
                    title: "Hide Navigation Bar on Scroll Down",
                    subtitle: "Only applies to some pages"
                )
                    .listPlainItemNoInsets()
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Miscellaneous")
    }
}
