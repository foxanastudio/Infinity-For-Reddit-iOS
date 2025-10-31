//
//  SubmitCommentViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-17.
//

import Foundation
import MarkdownUI
import SwiftUI
import GiphyUISDK

@MainActor
class SubmitCommentViewModel: ObservableObject {
    @Published var selectedAccount: Account
    @Published var text: String = ""
    @Published var embeddedImages: [UploadedImage] = []
    @Published var giphyGif: GPHMedia?
    @Published var submitCommentTask: Task<Void, Error>?
    @Published var submittedComment: Comment?
    @Published var error: Error? = nil
    
    let commentParent: CommentParent
    
    private let submitCommentRepository: SubmitCommentRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepositoryProtocol
    
    enum CommentSubmissionError: LocalizedError {
        case noContentError
        
        var errorDescription: String? {
            switch self {
            case .noContentError:
                return "Where are your interesting thoughts?"
            }
        }
    }
    
    init(commentParent: CommentParent,
         submitCommentRepository: SubmitCommentRepositoryProtocol,
         mediaUploadRepository: MediaUploadRepositoryProtocol
    ) {
        self.selectedAccount = AccountViewModel.shared.account
        self.commentParent = commentParent
        self.submitCommentRepository = submitCommentRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func submitComment() {
        guard submitCommentTask == nil else {
            return
        }
        
        guard !text.isEmpty else {
            error = CommentSubmissionError.noContentError
            return
        }
        
        submittedComment = nil
        
        submitCommentTask = Task {
            do {
                submittedComment = try await submitCommentRepository.submitComment(
                    accout: selectedAccount,
                    content: text,
                    parentFullname: commentParent.parentFullname ?? "",
                    depth: commentParent.childCommentDepth,
                    embeddedImages: embeddedImages,
                    giphyGif: giphyGif
                )
            } catch {
                self.error = error
                print("Error submitting comment: \(error)")
            }
            
            submitCommentTask = nil
        }
    }
    
    func addEmbeddedImage(_ image: UIImage) {
        let embeddedImage = UploadedImage(image: image) {
            try await self.mediaUploadRepository.uploadImage(account: self.selectedAccount, image: image, getImageId: true)
        }
        embeddedImage.upload()
        embeddedImages.append(embeddedImage)
    }
}
