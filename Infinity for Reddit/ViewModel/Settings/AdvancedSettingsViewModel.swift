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
    private let container: Container
    private let dbPool: DatabasePool
    
    init(container: Container = DependencyManager.shared.container) {
        self.container = container
        guard let resolvedPool = container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.dbPool = resolvedPool
    }
    
    func deleteAllSubreddits() async throws {

    }
    
    func deleteAllUsers() async throws {
        
    }
    
    func deleteAllSortTypes() async {
        
    }
    
    func deleteAllPostLayouts() async {
        
    }
    
    func deleteAllThemes() async throws {
        
    }
    
    func deleteFrontPagePositions() async {
        
    }
    
    func deleteReadPosts() async throws {
        
    }
    
    func deleteLegacySettings() async {
        
    }
    
    func resetAllSettings() async {
        
    }
    
    func backupSettings() async throws {

    }
    
    func restoreSettings() async throws {

    }
    
    func openCrashReports() {

    }
}
