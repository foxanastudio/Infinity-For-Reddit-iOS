//
//  CustomThemeSettingsViewNavigation.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-05.
//

enum CustomThemeSettingsViewNavigation: Hashable {
    case customizeCustomTheme(customThemeId: Int? = nil, predefindCustomThemeName: String? = nil, importedCustomTheme: CustomTheme? = nil)
    case customThemeListing
}
