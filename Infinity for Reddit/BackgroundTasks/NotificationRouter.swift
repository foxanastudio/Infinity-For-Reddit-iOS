//
// NotificationRouter.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-17
        
import Foundation

final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()
    private init() {}
    
    @Published var route: Route?
    
    struct Route: Equatable {
        enum Kind: Equatable {
            case openInbox(account: String, viewMessage: Bool, fullname: String?)
        }
        let kind: Kind
    }
    
    func postOpenInbox(account: String, viewMessage: Bool, fullname: String?) {
        Task {
            @MainActor in
            self.route = Route(kind: .openInbox(account: account, viewMessage: viewMessage, fullname: fullname))
        }
    }
}
