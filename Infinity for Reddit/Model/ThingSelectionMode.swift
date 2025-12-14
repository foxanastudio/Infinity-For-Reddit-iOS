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
    case subredditMultiSelection(selectedSubreddits: IdentifiedArrayOf<Thing>?, onConfirmSelection: ([Thing]) -> Void)
    case userMultiSelection(selectedUsers: IdentifiedArrayOf<Thing>?, onConfirmSelection: ([Thing]) -> Void)
    
    var isMultiSelection: Bool {
        switch self {
        case .subredditAndUserMultiSelection, .subredditMultiSelection:
            return true
        default:
            return false
        }
    }
}
