//
//  PostFilterUsageViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-03.
//

import Foundation
import GRDB
import Combine

class PostFilterUsageViewModel: ObservableObject {
    @Published var postFilterUsages: [PostFilterUsage] = []
    
    private let postFilterUsageRepository: PostFilterUsageRepositoryProtocol
    private let postFilterUsageDao: PostFilterUsageDao
    
    private var listener: AnyDatabaseCancellable?
    
    private let postFilterUsagesPublisher: AnyPublisher<[PostFilterUsage], Error>
    
    private var cancellables = Set<AnyCancellable>()
    
    init(postFilterId: Int, postFilterUsageRepository: PostFilterUsageRepositoryProtocol) {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.postFilterUsageRepository = postFilterUsageRepository
        self.postFilterUsageDao = PostFilterUsageDao(dbPool: resolvedDBPool)
        self.postFilterUsagesPublisher = postFilterUsageDao.getAllPostFilterUsageLiveData(postFilterId: postFilterId)
        
        postFilterUsagesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] postFilterUsages in
                self?.postFilterUsages = postFilterUsages
            })
            .store(in: &cancellables)
    }
    
    func deletePostFilterUsage(_ postFilterUsage: PostFilterUsage) {
        postFilterUsageRepository.deletePostFilterUsage(postFilterUsage)
    }
}
