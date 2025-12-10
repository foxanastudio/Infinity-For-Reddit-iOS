//
//  GesturesButtonsUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-10.
//

import Foundation

class GesturesButtonsUserDefaultsUtils {
    static let hideNavigationBarOnScrollDownKey = "hide_navigation_bar_on_scroll_down"
    static var hideNavigationBarOnScrollDown: Bool {
        return UserDefaults.miscellaneous.bool(forKey: hideNavigationBarOnScrollDownKey, false)
    }
}
