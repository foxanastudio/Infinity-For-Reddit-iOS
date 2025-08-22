//
//  SubmitCommentViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-17.
//

import Foundation
import MarkdownUI
import SwiftUI

class SubmitCommentViewModel: ObservableObject {
    @Published var selectedAccount: Account
    @Published var text: String = ""
    @Published var isSubmitting: Bool = false
    @Published var error: Error? = nil
    
    let commentParent: CommentParent
    
    private let submitCommentRepository: SubmitCommentRepositoryProtocol
    
    init(commentParent: CommentParent, submitCommentRepository: SubmitCommentRepositoryProtocol) {
        self.selectedAccount = AccountViewModel.shared.account
        self.commentParent = commentParent
        self.submitCommentRepository = submitCommentRepository
    }
    
    func submitComment() async -> Comment? {
        guard isSubmitting == false else { return nil }
        
        await MainActor.run {
            isSubmitting = true
        }
        
        var sentComment: Comment? = nil
        do {
            sentComment = try await submitCommentRepository.submitComment(
                accout: selectedAccount,
                content: text,
                parentFullname: commentParent.parentFullname ?? "",
                depth: commentParent.childCommentDepth
            )
        } catch {
            await MainActor.run {
                self.error = error
            }
            print("Error submitting comment: \(error)")
        }
        
        await MainActor.run {
            isSubmitting = false
        }
        
        return sentComment
    }
}
