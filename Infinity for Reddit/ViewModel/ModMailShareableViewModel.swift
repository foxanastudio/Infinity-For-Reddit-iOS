//
//  ModMailShareableViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-07-06.
//

import Foundation

@MainActor
class ModMailShareableViewModel: ObservableObject {
    @Published var updatedConversationDetail: ModMailConversationDetail?
    
    func consumeUpdatedConversationDetail() -> ModMailConversationDetail? {
        let detail = updatedConversationDetail
        updatedConversationDetail = nil
        return detail
    }
}
