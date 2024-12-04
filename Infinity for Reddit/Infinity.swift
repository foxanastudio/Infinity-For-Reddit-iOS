//
//  Infinity_for_RedditApp.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-27.
//

import SwiftUI
import Swinject

@main
struct Infinity: App {
    let container: Container = {
        let container = Container()
        return container
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.dependencyManager, DependencyManager.shared.container)
        }
    }
}
