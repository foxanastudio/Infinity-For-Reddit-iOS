//
//  Infinity_for_RedditApp.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-27.
//

import SwiftUI
import Swinject
import GRDB

@main
struct Infinity: App {
    let container: Container = {
        let container = Container()
        return container
    }()
    
    @StateObject var accountViewModel: AccountViewModel
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        _accountViewModel = StateObject(wrappedValue: AccountViewModel(dbPool: resolvedDBPool))
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.dependencyManager, DependencyManager.shared.container)
                .environmentObject(accountViewModel)
        }
    }
}
