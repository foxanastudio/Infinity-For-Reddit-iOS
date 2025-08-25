//
// SubredditChooseViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-24

import Foundation

@MainActor
class SubredditChooseViewModel: ObservableObject {
    
    @Published var selectedSubreddit: SubscribedSubredditData? = nil
    @Published var error: Error?
    @Published var rules: [Rule] = []
    
    private var ruleRepository: RuleRepositoryProtocol
    
    init(ruleRepository: RuleRepositoryProtocol) {
        self.ruleRepository = ruleRepository
    }
    
    func fetchRules(isAnonymous: Bool) async {
        do {
            try Task.checkCancellation()
            guard let name = selectedSubreddit?.name, !name.isEmpty else {
                self.rules = []
                return
            }
            
            let fetched = try await ruleRepository.fetchRules(subreddit: name, isAnonymous: isAnonymous)
            
            try Task.checkCancellation()
            
            self.rules = fetched
            
        } catch {
            self.rules = []
            print("Error fetching rules: \(error)")
        }
    }
}
