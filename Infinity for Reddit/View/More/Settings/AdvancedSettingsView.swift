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
    @State private var isPerformingAction = false
    
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 0) {
                    PreferenceEntry(title: "Delete All Subreddits in Database", icon: "tray.full") {
                        showConfirmation(for: .deleteSubreddits)
                    }
                    .disabled(isPerformingAction)
                    
                    PreferenceEntry(title: "Delete All Users in Database", icon: "person.3") {
                        showConfirmation(for: .deleteUsers)
                    }
                    .disabled(isPerformingAction)
                    
                    PreferenceEntry(title: "Delete All Sort Types in Database", icon: "arrow.up.arrow.down") {
                        showConfirmation(for: .deleteSortTypes)
                    }
                    .disabled(isPerformingAction)
                    
                    PreferenceEntry(title: "Delete All Post Layouts in Database", icon: "rectangle.3.offgrid") {
                        showConfirmation(for: .deletePostLayouts)
                    }
                    .disabled(isPerformingAction)
                    
                    PreferenceEntry(title: "Delete All Themes in Database", icon: "paintpalette") {
                        showConfirmation(for: .deleteThemes)
                    }
                    .disabled(isPerformingAction)
                    
                    PreferenceEntry(title: "Delete All Front Page Scrolled Positions in Database", icon: "arrow.uturn.backward") {
                        showConfirmation(for: .deleteFrontPagePositions)
                    }
                    .disabled(isPerformingAction)
                    
                    PreferenceEntry(title: "Delete All Read Posts in Database", icon: "book") {
                        showConfirmation(for: .deleteReadPosts)
                    }
                    .disabled(isPerformingAction)
                    
                    PreferenceEntry(title: "Reset All Settings", icon: "arrow.counterclockwise") {
                        showConfirmation(for: .resetAllSettings)
                    }
                    .disabled(isPerformingAction)
                }
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
                    handleAdvancedAction(action)
                }
            }
        )
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Advanced")
    }
    
    private func showConfirmation(for action: AdvancedAction) {
        guard !isPerformingAction else {
            return
        }
        withAnimation(.linear(duration: 0.2)) {
            pendingAction = action
        }
    }
    
    private func handleAdvancedAction(_ action: AdvancedAction) {
        switch action {
        case .deleteSubreddits:
            runAction(for: action) {
                try await advancedSettingsViewModel.deleteAllSubreddits()
            }
        case .deleteUsers:
            runAction(for: action) {
                try await advancedSettingsViewModel.deleteAllUsers()
            }
        case .deleteSortTypes:
            runAction(for: action) {
                await advancedSettingsViewModel.deleteAllSortTypes()
            }
        case .deletePostLayouts:
            runAction(for: action) {
                await advancedSettingsViewModel.deleteAllPostLayouts()
            }
        case .deleteThemes:
            runAction(for: action) {
                try await advancedSettingsViewModel.deleteAllThemes()
            }
        case .deleteFrontPagePositions:
            runAction(for: action) {
                await advancedSettingsViewModel.deleteFrontPagePositions()
            }
        case .deleteReadPosts:
            runAction(for: action) {
                try await advancedSettingsViewModel.deleteReadPosts()
            }
        case .resetAllSettings:
            runAction(for: action) {
                await advancedSettingsViewModel.resetAllSettings()
            }
        }
    }
    
    private func runAction(for action: AdvancedAction, perform block: @escaping () async throws -> Void) {
        isPerformingAction = true
        Task {
            do {
                try await block()
                await MainActor.run {
                    print("AdvancedSettings: showing success snackbar for", action)
                    snackbarManager.showSnackbar(.info(action.successMessage))
                }
            } catch {
                print("Advanced settings action failed:", error)
                await MainActor.run {
                    print("AdvancedSettings: showing error snackbar for", action)
                    snackbarManager.showSnackbar(.error(error))
                }
            }
            await MainActor.run {
                isPerformingAction = false
            }
        }
    }
}

private enum AdvancedAction {
    case deleteSubreddits
    case deleteUsers
    case deleteSortTypes
    case deletePostLayouts
    case deleteThemes
    case deleteFrontPagePositions
    case deleteReadPosts
    case resetAllSettings
    
    var successMessage: String {
        switch self {
        case .deleteSubreddits:
            return "Delete all subreddits successfully"
        case .deleteUsers:
            return "Delete all users successfully"
        case .deleteSortTypes:
            return "Delete all sort types successfully"
        case .deletePostLayouts:
            return "Delete all post layouts successfully"
        case .deleteThemes:
            return "Delete all themes successfully"
        case .deleteFrontPagePositions:
            return "Delete all scrolled positions in front page successfully"
        case .deleteReadPosts:
            return "Delete all read posts successfully"
        case .resetAllSettings:
            return "Reset all settings successfully"
        }
    }
}
