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
            errorMessage = nil
            isLoadingRules = false
            isLoadingFlairs = false
            
            if let name = selectedSubreddit?.name {
                rules = rulesDict[name] ?? []
                flairs = flairsDict[name] ?? []
            } else {
                rules = []
                flairs = []
            }
        }
    }
    @Published var errorMessage: String?
    @Published var rules: [Rule] = []
    @Published var flairs: [Flair] = []
    
    @Published var isLoadingRules: Bool = false
    @Published var isLoadingFlairs: Bool = false
    
    private var rulesDict: [String: [Rule]] = [:]
    private var flairsDict: [String: [Flair]] = [:]
    
    private var ruleRepository: RuleRepositoryProtocol
    private var flairRepository: FlairRepositoryProtocol
    
    init(ruleRepository: RuleRepositoryProtocol, flairRepository: FlairRepositoryProtocol) {
        self.ruleRepository = ruleRepository
        self.flairRepository = flairRepository
    }
    
    func fetchRules(isAnonymous: Bool, force: Bool = false) async {
        guard let name = selectedSubreddit?.name, !name.isEmpty else {
            self.rules = []
            return
        }
        
        if !force, let cached = rulesDict[name] {
            self.rules = cached
            return
        }
        
        isLoadingRules = true
        errorMessage = nil
        
        do {
            try Task.checkCancellation()
            let fetched = try await ruleRepository.fetchRules(subreddit: name, isAnonymous: isAnonymous)
            try Task.checkCancellation()
            
            rules = fetched
            rulesDict[name] = fetched
        } catch {
            rules = []
            errorMessage = "Failed to load rules: \(error.localizedDescription)"
            rulesDict[name] = []
        }
        
        isLoadingRules = false
    }
    
    func fetchFlairs(force: Bool = false) async {
        guard let name = selectedSubreddit?.name, !name.isEmpty else { return }
        
        if !force, let cached = flairsDict[name] {
            self.flairs = cached
            return
        }
        
        isLoadingFlairs = true
        errorMessage = nil
        
        do {
            try Task.checkCancellation()
            let fetched = try await flairRepository.fetchFlairs(subreddit: name)
            try Task.checkCancellation()
            
            flairs = fetched
            flairsDict[name] = fetched
        } catch {
            flairs = []
            errorMessage = "Failed to load flairs: \(error.localizedDescription)"
            flairsDict[name] = []
        }
        
        isLoadingFlairs = false
    }
}
