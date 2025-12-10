//
// MiscellaneousSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct MiscellaneousSettingsView: View {
    @AppStorage(MiscellaneousUserDefaultsUtils.saveLastSeenPostInFrontPageKey, store: .miscellaneous) private var saveLastSeenPostInFrontPage: Bool = false
    
    var body: some View {
        RootView {
            List {
                TogglePreference(isEnabled: $saveLastSeenPostInFrontPage, title: "Save Last Seen Post in Front Page")
                    .listPlainItemNoInsets()
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Miscellaneous")
    }
}
