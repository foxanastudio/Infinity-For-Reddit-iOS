//
//  CustomizeCustomThemeViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-29.
//

import Foundation
import GRDB

class CustomizeCustomThemeViewModel: ObservableObject {
    @Published var customTheme: CustomTheme
    
    private let customThemeDao: CustomThemeDao
    
    init(customTheme: CustomTheme) {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool")
        }
        
        self.customThemeDao = CustomThemeDao(dbPool: resolvedDatabasePool)
        
        self.customTheme = customTheme
    }
}
