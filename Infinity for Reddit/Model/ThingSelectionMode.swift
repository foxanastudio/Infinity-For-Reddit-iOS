//
//  SubscriptionSelectionMode.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import IdentifiedCollections

enum ThingSelectionMode {
    case noSelection
    case thingSelection(onSelectThing: (Thing) -> Void)
    case subredditAndUserMultiSelection(selectedSubredditsAndUsers: IdentifiedArrayOf<Thing>, onConfirmSelection: ([Thing]) -> Void)
    
    var isMultiSelection: Bool {
        switch self {
        case .subredditAndUserMultiSelection:
            return true
        default:
            return false
        }
    }
}
