//
//  CustomizeCustomThemeRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-10.
//

protocol CustomizeCustomThemeRepositoryProtocol {
    func getCustomTheme(customThemeId: Int?, predefindCustomThemeName: String?, importedCustomTheme: CustomTheme?) async throws -> CustomTheme?
    func saveCustomTheme(customTheme: CustomTheme) async throws
}
