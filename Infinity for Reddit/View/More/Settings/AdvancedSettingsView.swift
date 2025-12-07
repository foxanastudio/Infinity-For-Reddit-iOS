//
// AdvancedSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI

struct AdvancedSettingsView: View {
    @StateObject private var viewModel = AdvancedSettingsViewModel()
    
    var body: some View {
        RootView {
            List {
                CustomListSection("Database") {
                    PreferenceEntry(title: "Delete All Subreddits in Database", icon: "tray.full") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Delete All Users in Database", icon: "person.3") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Delete All Sort Types in Database", icon: "arrow.up.arrow.down") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Delete All Post Layouts in Database", icon: "rectangle.3.offgrid") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Delete All Themes in Database", icon: "paintpalette") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Delete All Front Page Scrolled Positions in Database", icon: "arrow.uturn.backward") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Delete All Read Posts in Database", icon: "book") { }
                    .listPlainItemNoInsets()
                }
                
                CustomListSection("Preferences") {
                    PreferenceEntry(title: "Delete All Legacy Settings", icon: "clock.arrow.circlepath") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Reset All Settings", icon: "arrow.counterclockwise") { }
                    .listPlainItemNoInsets()
                }
                
                CustomListSection("Backup & Restore") {
                    PreferenceEntry(title: "Backup Settings", icon: "arrow.up.doc") { }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(title: "Restore Settings", icon: "arrow.down.doc") { }
                    .listPlainItemNoInsets()
                }
                
                CustomListSection("Diagnostics") {
                    PreferenceEntry(title: "Crash Reports", icon: "exclamationmark.triangle") { }
                    .listPlainItemNoInsets()
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Advanced")
    }
}
