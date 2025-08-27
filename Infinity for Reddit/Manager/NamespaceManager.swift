//
//  NamespaceManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-04.
//

import Foundation
import SwiftUICore

class NamespaceManager: ObservableObject {
    var animation: Namespace.ID
    
    init(_ namespace: Namespace.ID) {
        self.animation = namespace
    }
}
