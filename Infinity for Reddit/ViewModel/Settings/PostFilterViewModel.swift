//
//  PostFilterViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-08.
//

import SwiftUI
import Combine
import GRDB

class PostFilterViewModel: ObservableObject {
    // MARK: - Properties
    @Published var postFilters: [PostFilter] = []
    
    let postToBeAdded: Post?
    let subredditToBeAdded: String?
    let userToBeAdded: String?
    private let postFilterRepository: PostFilterRepositoryProtocol
    private let postFilterDao: PostFilterDao
    private let dbPool: DatabasePool
    
    private var listener: AnyDatabaseCancellable?
    
    // MARK: - Initializer
    init(postToBeAdded: Post?, subredditToBeAdded: String?, userToBeAdded: String?, postFilterRepository: PostFilterRepositoryProtocol) {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.postToBeAdded = postToBeAdded
        self.subredditToBeAdded = subredditToBeAdded
        self.userToBeAdded = userToBeAdded
        self.postFilterRepository = postFilterRepository
        self.postFilterDao = PostFilterDao(dbPool: resolvedDBPool)
        self.dbPool = resolvedDBPool
        
        loadPostFilters()
    }
    
    // MARK: - Methods
    func loadPostFilters() {
        listener = ValueObservation
            .tracking { db in
                try PostFilter.fetchAll(db, sql: "SELECT * FROM post_filter ORDER BY name")
            }
            .start(in: dbPool) { error in
                print("Error observing post filters: \(error)")
                // TODO Handle error
            } onChange: { (postFilters: [PostFilter]) in
                self.postFilters = postFilters
            }
    }
    
    func deletePostFilter(id: Int) {
        postFilterRepository.deletePostFilter(id: id)
    }
    
    deinit {
        listener?.cancel()
    }
}
