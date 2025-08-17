//
//  UserDefaults.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-16.
//

import Foundation

public extension UserDefaults {
    static let contentSensitivityFilter = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.content_sensitivity_filter")!
    static let interfaceComment = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.interface_comment")!
    static let postHistory = UserDefaults.standard
    static let sortType = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.sort_type")
}
