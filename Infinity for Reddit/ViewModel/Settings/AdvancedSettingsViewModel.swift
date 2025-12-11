//
//  AdvancedSettingsViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-04.
//

import Foundation
import Swinject
import GRDB

@MainActor
final class AdvancedSettingsViewModel: ObservableObject {
    @Published var successMessage: String?
    @Published var error: Error?
    
    private let subredditDao: SubredditDao
    private let userDao: UserDao
    private let postHistoryDao: PostHistoryDao
    private let customThemeDao: CustomThemeDao
    
    init() {
        guard let resolvedPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool in AdvancedSettingsViewModel")
        }
        self.subredditDao = SubredditDao(dbPool: resolvedPool)
        self.userDao = UserDao(dbPool: resolvedPool)
        self.postHistoryDao = PostHistoryDao(dbPool: resolvedPool)
        self.customThemeDao = CustomThemeDao(dbPool: resolvedPool)
    }
    
    private func deleteAllSubreddits() async throws {
        try await subredditDao.deleteAllSubreddits()
    }
    
    private func deleteAllUsers() async throws {
        try await userDao.deleteAllUsers()
    }
    
    private func deleteAllSortTypes() {
        guard let sortTypeDefaults = UserDefaults.sortType else {
            return
        }
        
        sortTypeDefaults.dictionaryRepresentation().keys.forEach {
            sortTypeDefaults.removeObject(forKey: $0)
        }
    }
    
    private func deleteAllPostLayouts() {
        if let postLayoutDefaults = UserDefaults.postLayout {
            postLayoutDefaults.dictionaryRepresentation().keys.forEach {
                postLayoutDefaults.removeObject(forKey: $0)
            }
        }
        
        UserDefaults.interfacePost.removeObject(forKey: InterfacePostUserDefaultsUtils.defaultPostLayoutKey)
        UserDefaults.interfacePost.removeObject(forKey: InterfacePostUserDefaultsUtils.defaultLinkPostLayoutKey)
    }
    
    private func deleteAllThemes() async throws {
        try await customThemeDao.deleteAllCustomThemes()
    }
    
    private func deleteFrontPagePositions() {
        MiscellaneousUserDefaultsUtils.frontPagePositionKeys().forEach {
            UserDefaults.miscellaneous.removeObject(forKey: $0)
        }
    }
    
    private func deleteReadPosts() async throws {
        try await postHistoryDao.deleteAllReadPosts()
    }
    
    private func resetAllSettings() {
        let disableSensitiveContentForever = ContentSensitivityFilterUserDetailsUtils.disableSensitiveContentForever
        
        for defaults in UserDefaultsResetTargets.stores {
            defaults.dictionaryRepresentation().keys.forEach {
                defaults.removeObject(forKey: $0)
            }
        }
        
        if disableSensitiveContentForever {
            UserDefaults.contentSensitivityFilter.set(
                true,
                forKey: ContentSensitivityFilterUserDetailsUtils.disableSensitiveContentForeverKey)
        }
    }
    
    func handleAdvancedAction(_ action: AdvancedAction) {
        switch action {
        case .deleteSubreddits:
            runAction(for: action) {
                try await self.deleteAllSubreddits()
            }
        case .deleteUsers:
            runAction(for: action) {
                try await self.deleteAllUsers()
            }
        case .deleteSortTypes:
            runAction(for: action) {
                self.deleteAllSortTypes()
            }
        case .deletePostLayouts:
            runAction(for: action) {
                self.deleteAllPostLayouts()
            }
        case .deleteThemes:
            runAction(for: action) {
                try await self.deleteAllThemes()
            }
        case .deleteFrontPagePositions:
            runAction(for: action) {
                self.deleteFrontPagePositions()
            }
        case .deleteReadPosts:
            runAction(for: action) {
                try await self.deleteReadPosts()
            }
        case .resetAllSettings:
            runAction(for: action) {
                self.resetAllSettings()
            }
        }
    }
    
    private func runAction(for action: AdvancedAction, perform block: @escaping () async throws -> Void) {
        Task {
            do {
                try await block()
                self.successMessage = action.successMessage
            } catch {
                print("Advanced settings action failed:", error)
                self.error = error
            }
        }
    }
}

enum AdvancedAction {
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
