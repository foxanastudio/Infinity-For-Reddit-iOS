//
//  ModMailState.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-28.
//

import Foundation

enum ModMailState: String, CaseIterable {
    case all
    case mod
    
    var title: String {
        switch self {
        case .all:
            return "Mod Mail"
        case .mod:
            return "Mod Discussions"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "tray.full"
        case .mod:
            return "shield"
        }
    }
}
