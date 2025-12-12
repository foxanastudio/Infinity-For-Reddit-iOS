//
//  Bundle.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-14.
//

import Foundation

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
