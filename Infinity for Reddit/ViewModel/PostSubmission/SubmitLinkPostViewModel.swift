//
// SubmitLinkPostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-09-13

import Foundation
import MarkdownUI
import Alamofire

@MainActor
class SubmitLinkPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var urlString: String = ""
    @Published var content: String = ""
    @Published var selectedAccount: Account
    @Published var suggestTitleTask: Task<Void, Error>?
    @Published var submitPostTask: Task<Void, Error>?
    @Published var submittedPostId: String?
    @Published var error: Error? = nil
    
    private let session: Session
    private let submitPostRepository: SubmitPostRepositoryProtocol
    
    enum SubmitLinkPostViewModelError: LocalizedError {
        case noTitleFound
        case failedToSuggestTitle(String)
        
        var errorDescription: String? {
            switch self {
            case .noTitleFound:
                return "No title found in URL"
            case .failedToSuggestTitle(let message):
                return "Failed to suggest title: \(message)"
            }
        }
    }
    
    init(submitPostRepository: SubmitPostRepositoryProtocol) {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self, name: "plain") else {
            fatalError("Failed to resolve plain Session in SubmitLinkPostViewModel")
        }
        self.session = resolvedSession
        
        self.selectedAccount = AccountViewModel.shared.account
        self.submitPostRepository = submitPostRepository
    }
    
    func suggestTitle() {
        suggestTitleTask?.cancel()
        
        suggestTitleTask = Task {
            var finalURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !finalURL.lowercased().hasPrefix("http://") &&
                !finalURL.lowercased().hasPrefix("https://") {
                finalURL = "https://" + finalURL
            }
            
            guard var components = URLComponents(string: finalURL), let host = components.host else {
                print("Invalid URL: \(finalURL)")
                return
            }
            
            if !host.contains("www.") && host.components(separatedBy: ".").count == 2 {
                components.host = "www." + host
            }
            
            guard let safeURL = components.url else {
                print("Failed to build safe URL")
                return
            }
            
            print("Final safe URL: \(safeURL)")
            
            do {
                let html = try await session.request(safeURL, method: .get)
                    .validate()
                    .serializingString(automaticallyCancelling: true)
                    .value
                
                if let start = html.range(of: "<title>", options: .caseInsensitive),
                   let end = html.range(of: "</title>", options: .caseInsensitive) {
                    let title = String(html[start.upperBound..<end.lowerBound])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    do {
                        try Task.checkCancellation()
                    } catch {
                        // Ignore
                    }
                    
                    await MainActor.run {
                        self.title = title
                    }
                } else {
                    self.error = SubmitLinkPostViewModelError.noTitleFound
                }
            } catch {
                self.error = SubmitLinkPostViewModelError.failedToSuggestTitle(error.localizedDescription)
            }
            
            await MainActor.run {
                suggestTitleTask = nil
            }
        }
    }
    
    func submitPost(
        subreddit: SubscribedSubredditData?,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) {
        guard submitPostTask == nil else {
            return
        }
        
        guard let subreddit = subreddit, !subreddit.name.isEmpty else {
            error = PostSubmissionError.subredditNotSelectedError
            return
        }
        
        guard !title.isEmpty else {
            error = PostSubmissionError.noTitleError
            return
        }
        
        guard !urlString.isEmpty else {
            error = PostSubmissionError.noURLError
            return
        }
        
        submittedPostId = nil
        
        submitPostTask = Task {
            do {
                submittedPostId = try await submitPostRepository.submitLinkPost(
                    account: selectedAccount,
                    subredditName: subreddit.name,
                    title: title,
                    urlString: urlString,
                    content: content,
                    flair: flair,
                    isSpoiler: isSpoiler,
                    isSensitive: isSensitive,
                    receivePostReplyNotifications: receivePostReplyNotifications
                )
            } catch {
                self.error = error
                print(error)
            }
            
            self.submitPostTask = nil
        }
    }
}
