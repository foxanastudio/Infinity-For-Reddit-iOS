//
//  DependencyManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-29.
//

import Swinject
import Alamofire
import GRDB
import Foundation

struct DependencyManager {
    static let shared = DependencyManager()
    
    let container: Container
    
    private init() {
        container = Container()
        registerDependencies(container)
    }
    
    private func registerDependencies(_ c: Container) {
        // TODO register dependencies on container
        c.register(Session.self) {_ in
            let configuration = URLSessionConfiguration.af.default
            return Session(configuration: configuration)
        }
        c.register(DatabasePool.self) {_ in
            do {
                return try RedditGRDBDatabase.create()
            } catch {
                fatalError("Failed to create DatabasePool: \(error)")
            }
        }
    }
}
