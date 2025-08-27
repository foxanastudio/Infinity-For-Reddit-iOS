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
        c.register(Session.self) { _ in
            let configuration = URLSessionConfiguration.af.default
            return Session(configuration: configuration, interceptor: RedditAccessTokenInterceptor())
        }.inObjectScope(.container) // Singleton
        
        c.register(Session.self, name: "plain") { _ in
            let configuration = URLSessionConfiguration.af.default
            return Session(configuration: configuration)
        }.inObjectScope(.container)
        
        c.register(DatabasePool.self) { _ in
            do {
                return try RedditGRDBDatabase.create()
            } catch {
                fatalError("Failed to create DatabasePool: \(error)")
            }
        }.inObjectScope(.container) // Singleton
        
        c.register(OperationQueue.self) { _ in
            let operationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 4
            return operationQueue
        }.inObjectScope(.container) // Singleton
        
        c.register(UserDefaults.self) { _ in
            UserDefaults.standard
        }.inObjectScope(.container) // Singleton
        
        c.register(UserDefaults.self, name: "PostDetails") { _ in
            return UserDefaults(suiteName: "com.docilealligator.infinityforReddit.PostDetails")!
        }.inObjectScope(.container) // Singleton
    }
}
