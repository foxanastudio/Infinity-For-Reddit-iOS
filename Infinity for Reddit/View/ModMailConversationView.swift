//
//  ModMailConversationView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-14.
//

import Alamofire
import SwiftUI

struct ModMailConversationView: View {
    let conversationId: String
    let participantUsername: String
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        RootView {
            Text("ModMailConversationView")
        }
        .task {
            await loadModMailConversation()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar(participantUsername)
    }
    
    private func loadModMailConversation() async {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        do {
            guard let session = DependencyManager.shared.container.resolve(Session.self) else {
                throw APIError.invalidResponse("Failed to resolve Session")
            }
            
            let data = try await session.request(RedditOAuthAPI.getModMailConversation(conversationId: conversationId))
                .validate()
                .serializingData()
                .value
            
            try Task.checkCancellation()
            
            if let responseText = String(data: data, encoding: .utf8) {
                printInDebugOnly(responseText)
            }
            isLoading = false
        } catch {
            if !(error is CancellationError) {
                printInDebugOnly("Cannot fetch mod mail conversation.")
            }
            
            isLoading = false
        }
    }
}
