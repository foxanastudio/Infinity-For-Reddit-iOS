//
//  SubredditAutoCompleteViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-01.
//

import Foundation
import IdentifiedCollections

@MainActor
class SubredditAutoCompleteViewModel: ObservableObject {
    @Published var subreddits: [Subreddit] = []
    
    @Published var selectedSubreddits: IdentifiedArrayOf<Subreddit> = []
    @Published var selectedSubscribedSubreddits: IdentifiedArrayOf<SubscribedSubredditData> = []
    @Published var selectedSubredditData: IdentifiedArrayOf<SubredditData> = []
    @Published var selectedSubredditsInCustomFeed: IdentifiedArrayOf<SubredditInCustomFeed> = []
    
    let thingSelectionMode: ThingSelectionMode
    
    private var fetchSubredditsTask: Task<Void, Never>?
    
    private let subredditAutoCompleteRepository: SubredditAutoCompleteRepositoryProtocol
    
    init(thingSelectionMode: ThingSelectionMode, subredditAutoCompleteRepository: SubredditAutoCompleteRepositoryProtocol) {
        self.thingSelectionMode = thingSelectionMode
        switch thingSelectionMode {
        case .subredditAndUserMultiSelection(let selectedSubredditsAndUsers, _):
            var selectedSubscribedSubreddits = IdentifiedArrayOf<SubscribedSubredditData>()
            var selectedSubredditData = IdentifiedArrayOf<SubredditData>()
            var selectedSubredditsInCustomFeed = IdentifiedArrayOf<SubredditInCustomFeed>()
            
            for item in selectedSubredditsAndUsers {
                switch item {
                case .subscribedSubreddit(let subscribedSubredditData):
                    selectedSubscribedSubreddits.append(subscribedSubredditData)
                case .subreddit(let subredditData):
                    selectedSubredditData.append(subredditData)
                case .subredditInCustomFeed(let subredditInCustomFeed):
                    selectedSubredditsInCustomFeed.append(subredditInCustomFeed)
                case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
                    selectedSubredditsInCustomFeed.append(SubredditInCustomFeed(name: anonymousCustomFeedSubreddit.subredditName))
                case .subscribedUser:
                    break
                case .user:
                    break
                case .myCustomFeed:
                    break
                }
            }
            
            self.selectedSubscribedSubreddits = selectedSubscribedSubreddits
            self.selectedSubredditData = selectedSubredditData
            self.selectedSubredditsInCustomFeed = selectedSubredditsInCustomFeed
        default:
            break
        }
        self.subredditAutoCompleteRepository = subredditAutoCompleteRepository
    }
    
    func fetchSubredditsAutoComplete(query: String, over18: Bool) {
        fetchSubredditsTask?.cancel()
        
        fetchSubredditsTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                try Task.checkCancellation()
                
                let subredditListing = try await self.subredditAutoCompleteRepository.getSubredditAutoComplete(query: query, over18: over18)
                
                try Task.checkCancellation()
                
                self.subreddits = subredditListing.subreddits
            } catch {
                // Ignore
                print(error)
            }
            
            fetchSubredditsTask = nil
        }
    }
    
    func clearSubreddits() {
        subreddits.removeAll()
    }
    
    func toggleSelection(subreddit: Subreddit) {
        if selectedSubreddits.index(id: subreddit.id) != nil {
            selectedSubreddits.remove(subreddit)
        } else if selectedSubredditData.index(id: subreddit.id) != nil {
            selectedSubredditData.remove(id: subreddit.id)
        } else if selectedSubscribedSubreddits.index(id: subreddit.id) != nil {
            selectedSubscribedSubreddits.remove(id: subreddit.id)
        } else if selectedSubredditsInCustomFeed.index(id: subreddit.name) != nil {
            selectedSubredditsInCustomFeed.remove(id: subreddit.name)
        } else {
            selectedSubreddits.append(subreddit)
        }
    }
}
