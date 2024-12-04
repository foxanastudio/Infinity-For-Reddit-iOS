//
//  InboxView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import SwiftUI
import Swinject
import GRDB

struct InboxView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    var body: some View {
        Text("Inbox")
    }
}
