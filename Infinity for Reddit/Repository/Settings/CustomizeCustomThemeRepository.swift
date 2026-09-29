//
//  CustomizeCustomThemeRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-10.
//

import GRDB

class CustomizeCustomThemeRepository: CustomizeCustomThemeRepositoryProtocol {
    private let customThemeDao: CustomThemeDao
    
    init() {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool in CustomizeCustomThemeRepository")
        }
        
        self.customThemeDao = CustomThemeDao(dbPool: resolvedDatabasePool)
    }
    
    func getCustomTheme(customThemeId: Int?, predefindCustomThemeName: String?, importedCustomTheme: CustomTheme?) async throws -> CustomTheme? {
        if let id = customThemeId {
            return try await customThemeDao.getCustomTheme(id: id)
        } else if let name = predefindCustomThemeName {
            return CustomTheme.getPredefinedTheme(name: name)
        } else if let importedCustomTheme {
            return importedCustomTheme
        } else {
            return CustomTheme.getIndigo()
        }
    }
    
    func saveCustomTheme(customTheme: CustomTheme) async throws {
        if customTheme.isLightTheme {
            try await customThemeDao.unsetLightTheme()
        }
        
        if customTheme.isDarkTheme {
            try await customThemeDao.unsetDarkTheme()
        }
        
        if customTheme.isAmoledTheme {
            try await customThemeDao.unsetAmoledTheme()
        }
        
        try await customThemeDao.insert(customTheme: customTheme)
    }
}
