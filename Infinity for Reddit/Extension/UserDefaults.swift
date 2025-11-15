//
//  UserDefaults.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-16.
//

import Foundation

extension UserDefaults {
    static let contentSensitivityFilter = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.content_sensitivity_filter")!
    static let interfaceComment = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.interface_comment")!
    static let postHistory = UserDefaults.standard
    static let sortType = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.sort_type")
    static let sortTypeSettings = UserDefaults.standard
    static let theme = UserDefaults.standard
    static let video = UserDefaults.standard
    static let notification = UserDefaults.standard
    static let interfacePost = UserDefaults.standard
    static let interfacePostDetails = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.interface_post_details")!
    static let interfaceTimeFormat = UserDefaults.standard
    static let interface = UserDefaults.standard
    static let token = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.token")!
    static let postLayout = UserDefaults(suiteName: "com.docilealligator.infinityforreddit.post_layout")
    static let interfaceFont = UserDefaults.standard
}

extension UserDefaults {
    func bool(forKey key: String, _ defaultValue: Bool) -> Bool {
        object(forKey: key) == nil ? defaultValue : bool(forKey: key)
    }
    
    func double(forKey key: String, _ defaultValue: Double) -> Double {
        object(forKey: key) == nil ? defaultValue : double(forKey: key)
    }
    
    func integer(forKey key: String, _ defaultValue: Int) -> Int {
        object(forKey: key) == nil ? defaultValue : integer(forKey: key)
    }
    
    func string(forKey key: String, _ defaultValue: String) -> String {
        object(forKey: key) == nil ? defaultValue : string(forKey: key) ?? ""
    }
}
