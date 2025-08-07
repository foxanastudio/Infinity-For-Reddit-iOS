//
//  CustomizeCommentFilterViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-06.
//

import Foundation

public class CustomizeCommentFilterViewModel: ObservableObject {
    @Published private var id: Int? = nil
    @Published var name: String = "New Filter"
    @Published var displayMode: CommentFilter.DisplayMode = .removeComment
    @Published var excludesKeywords: String = ""
    @Published var excludeUsers: String = ""
    @Published var minVote: Int = -1
    @Published var minVoteString: String = "-1"
    @Published var maxVote: Int = -1
    @Published var maxVoteString: String = "-1"
    
    private let customizeCommentFilterRepository: CustomizeCommentFilterRepositoryProtocol
    
    init(commentFilter: CommentFilter?, customizeCommentFilterRepository: CustomizeCommentFilterRepositoryProtocol) {
        if let commentFilter = commentFilter {
            id = commentFilter.id
            name = commentFilter.name
            displayMode = commentFilter.displayMode
            excludesKeywords = commentFilter.excludeStrings ?? ""
            excludeUsers = commentFilter.excludeUsers ?? ""
            minVote = commentFilter.minVote
            minVoteString = String(commentFilter.minVote)
            maxVote = commentFilter.maxVote
            maxVoteString = String(commentFilter.maxVote)
        }
        
        self.customizeCommentFilterRepository = customizeCommentFilterRepository
    }
    
    func saveCommentFilter() -> Bool {
        let commentFilter = CommentFilter(
            id: id,
            name: name,
            displayMode: displayMode,
            maxVote: maxVote,
            minVote: minVote,
            excludeStrings: excludesKeywords,
            excludeUsers: excludeUsers
        )
        
        return customizeCommentFilterRepository.saveCommentFilter(commentFilter)
    }
}
