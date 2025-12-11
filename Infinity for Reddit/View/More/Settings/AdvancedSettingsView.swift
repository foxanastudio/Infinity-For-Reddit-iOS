//
// AdvancedSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI

struct AdvancedSettingsView: View {
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var advancedSettingsViewModel = AdvancedSettingsViewModel()
    
    @State private var pendingAction: AdvancedAction?
    
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 0) {
                    PreferenceEntry(title: "Delete All Subreddits in Database", icon: "tray.full") {
                        showConfirmation(for: .deleteSubreddits)
                    }
                    
                    PreferenceEntry(title: "Delete All Users in Database", icon: "person.3") {
                        showConfirmation(for: .deleteUsers)
                    }
                    
                    PreferenceEntry(title: "Delete All Sort Types in Database", icon: "arrow.up.arrow.down") {
                        showConfirmation(for: .deleteSortTypes)
                    }
                    
                    PreferenceEntry(title: "Delete All Post Layouts in Database", icon: "rectangle.3.offgrid") {
                        showConfirmation(for: .deletePostLayouts)
                    }
                    
                    PreferenceEntry(title: "Delete All Themes in Database", icon: "paintpalette") {
                        showConfirmation(for: .deleteThemes)
                    }
                    
                    PreferenceEntry(title: "Delete All Front Page Scrolled Positions in Database", icon: "arrow.uturn.backward") {
                        showConfirmation(for: .deleteFrontPagePositions)
                    }
                    
                    PreferenceEntry(title: "Delete All Read Posts in Database", icon: "book") {
                        showConfirmation(for: .deleteReadPosts)
                    }
                    
                    PreferenceEntry(title: "Reset All Settings", icon: "arrow.counterclockwise") {
                        showConfirmation(for: .resetAllSettings)
                    }
                }
            }
        }
        .showErrorUsingSnackbar(advancedSettingsViewModel.$error)
        .onChange(of: advancedSettingsViewModel.successMessage) { _, newValue in
            if let newValue {
                snackbarManager.showSnackbar(.info(newValue))
            }
        }
        .overlay(
            CustomAlert(
                title: "Are you sure?",
                buttonStyle: .warning,
                isPresented: Binding(
                    get: { pendingAction != nil },
                    set: { newValue in
                        if !newValue {
                            pendingAction = nil
                        }
                    }
                )
            ) {
                EmptyView()
            } onConfirm: {
                if let action = pendingAction {
                    pendingAction = nil
                    advancedSettingsViewModel.handleAdvancedAction(action)
                }
            }
        )
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Advanced")
    }
    
    private func showConfirmation(for action: AdvancedAction) {
        withAnimation {
            pendingAction = action
        }
    }
}
