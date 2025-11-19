//
//  CreateCustomFeedViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import Foundation

class CreateCustomFeedViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var createCustomFeedTask: Task<Void, Never>?
    @Published var customFeedCreatedFlag: Bool = false
    @Published var error: Error? = nil
    
    private let createCustomFeedRepository: CreateCustomFeedRepositoryProtocol
    
    init(createCustomFeedRepository: CreateCustomFeedRepositoryProtocol) {
        self.createCustomFeedRepository = createCustomFeedRepository
    }
}
