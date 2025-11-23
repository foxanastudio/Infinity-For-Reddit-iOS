//
//  InboxRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-16.
//

import Alamofire

class InboxRepository: InboxRepositoryProtocol {
    private let session: Session
    
    init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in FlairRepository")
        }
        self.session = resolvedSession
    }
    
    func readAllMessages() async {
        await self.session.request(RedditOAuthAPI.readAllMessages)
            .validate()
            .serializingData()
            .response
    }
}
