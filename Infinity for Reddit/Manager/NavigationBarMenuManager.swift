//
//  NavigationBarMenuManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-01.
//

import Foundation

public class NavigationBarMenuManager: ObservableObject {
    @Published private var itemDict: [UUID : [NavigationBarMenuItem]] = [:]
    
    var items: [NavigationBarMenuItem] {
        itemDict.flatMap { $1 }
    }
    
    func push(_ items: [NavigationBarMenuItem]) -> UUID {
        let key = UUID()
        itemDict[key] = items
        return key
    }
    
    func pop(key: UUID) {
        itemDict.removeValue(forKey: key)
    }
}
