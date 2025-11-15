//
//  InterfaceFontUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-12.
//

import Foundation

class InterfaceFontUserDefaultsUtils {
    static let fontFamilies = [0, 1]
    static let fontFamiliesText = ["Default", "Balsamiq Sans"]
    static let fontSizes = [0, 1, 2, 3, 4]
    static let fontSizesText = ["Extra Small", "Small", "Normal", "Large", "Extra Large"]
    static let contentFontSizes = [0, 1, 2, 3, 4, 5]
    static let contentFontSizesText = ["Extra Small", "Small", "Normal", "Large", "Extra Large", "Enormously Large"]
    
    static let fontFamilyKey = "fontFamilyKey"
    static var fontFamily: Int {
        return UserDefaults.interfaceFont.integer(forKey: fontFamilyKey)
    }
    
    static let fontSizeKey = "fontSizeKey"
    static var fontSize: Int {
        return UserDefaults.interfaceFont.integer(forKey: fontSizeKey)
    }
    
    static let titleFontFamilyKey = "titleFontFamilyKey"
    static var titleFontFamily: Int {
        return UserDefaults.interfaceFont.integer(forKey: titleFontFamilyKey)
    }
    
    static let titleFontSizeKey = "titleFontSizeKey"
    static var titleFontSize: Int {
        return UserDefaults.interfaceFont.integer(forKey: titleFontSizeKey)
    }
    
    static let contentFontFamilyKey = "contentFontFamilyKey"
    static var contentFontFamily: Int {
        return UserDefaults.interfaceFont.integer(forKey: contentFontFamilyKey)
    }
    
    static let contentFontSizeKey = "contentFontSizeKey"
    static var contentFontSize: Int {
        return UserDefaults.interfaceFont.integer(forKey: contentFontSizeKey)
    }
}
