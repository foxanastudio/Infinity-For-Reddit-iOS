//
// SubredditChooseViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-24

import Foundation

@MainActor
class SubredditChooseViewModel: ObservableObject {
    
    @Published var selectedSubreddit: SubscribedSubredditData? = nil {
        didSet {
            
            rules = []
            flairs = []
            
            if let subreddit = selectedSubreddit, !subreddit.name.isEmpty {
                Task {
                    await fetchRules(isAnonymous: false)
                    await fetchFlairs()
                }
            }
        }
    }
    @Published var error: Error?
    @Published var rules: [Rule] = []
    @Published var flairs: [Flair] = []
    
    private var ruleRepository: RuleRepositoryProtocol
    private var flairRepository: FlairRepositoryProtocol
    
    init(ruleRepository: RuleRepositoryProtocol, flairRepository: FlairRepositoryProtocol) {
        self.ruleRepository = ruleRepository
        self.flairRepository = flairRepository
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
            
            print(rules)
            
        } catch {
            self.rules = []
            print("Error fetching rules: \(error)")
        }
    }
    
    func fetchFlairs() async {
        do {
            try Task.checkCancellation()
            guard let name = selectedSubreddit?.name, !name.isEmpty else {
                self.flairs = []
                return
            }
            
            let fetched = try await flairRepository.fetchFlairs(subreddit: name)
            
            try Task.checkCancellation()
            
            self.flairs = fetched
            
            print(flairs)
            
        } catch {
            self.flairs = []
            print("Error fetching flairs: \(error)")
        }
    }
}
