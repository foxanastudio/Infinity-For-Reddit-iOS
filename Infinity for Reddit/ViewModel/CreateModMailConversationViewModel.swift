//
//  CreateModMailConversationViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-07.
//

import Foundation

@MainActor
class CreateModMailConversationViewModel: ObservableObject {
    @Published var moderatedSubreddits: [ModeratedSubreddit] = []
    @Published var selectedSubreddit: ModeratedSubreddit?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let createModMailConversationRepository: CreateModMailConversationRepositoryProtocol
    
    init(createModMailConversationRepository: CreateModMailConversationRepositoryProtocol) {
        self.createModMailConversationRepository = createModMailConversationRepository
    }
    
    func loadModeratedSubreddits() async {
        isLoading = true
        error = nil
        
        do {
            try Task.checkCancellation()
            
            let moderatedSubreddits = try await createModMailConversationRepository.fetchModeratedSubreddits()
            
            try Task.checkCancellation()
            
            self.moderatedSubreddits = moderatedSubreddits.sorted { $0.name.lowercased() < $1.name.lowercased() }
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Cannot fetch moderated subreddits: \(error)")
            }
        }
        isLoading = false
    }
}
