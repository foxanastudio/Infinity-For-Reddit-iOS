//
//  ModMailConversationViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-15.
//

import Foundation

@MainActor
class ModMailConversationViewModel: ObservableObject {
    @Published var modMailConversationDetail: ModMailConversationDetail?
    @Published var isLoading: Bool = false
    @Published var isInitialLoad: Bool = true
    @Published var error: Error?

    private let conversationId: String
    private let modMailConversationRepository: ModMailConversationRepositoryProtocol
    
    init(conversationId: String, modMailConversationRepository: ModMailConversationRepositoryProtocol) {
        self.conversationId = conversationId
        self.modMailConversationRepository = modMailConversationRepository
    }

    func initialLoadModMailConversation() async {
        guard isInitialLoad else {
            return
        }

        await loadModMailConversation()
    }

    func loadModMailConversation() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        let isInitialLoadCopy = isInitialLoad

        if isInitialLoad {
            isInitialLoad = false
        }

        do {
            try Task.checkCancellation()

            let response = try await modMailConversationRepository.fetchModMailConversation(
                conversationId: conversationId,
                interceptor: nil
            )

            try Task.checkCancellation()

            let modMailConversationDetail = try ModMailConversationDetail(fromJson: response)
            self.modMailConversationDetail = modMailConversationDetail
            self.isLoading = false
        } catch {
            if !(error is CancellationError) {
                self.error = error
                printInDebugOnly("Cannot fetch mod mail conversation: \(error)")
            }
            self.isInitialLoad = isInitialLoadCopy

            self.isLoading = false
        }
    }
}
