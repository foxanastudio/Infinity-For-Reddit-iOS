//
//  EditCommentViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-31.
//

import Foundation
import MarkdownUI
import SwiftUI
import GiphyUISDK

@MainActor
class EditCommentViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var embeddedImages: [UploadedImage] = []
    @Published var giphyGif: GPHMedia?
    @Published var editCommentTask: Task<Void, Error>?
    @Published var editedComment: Comment?
    @Published var error: Error? = nil
    
    let commentToBeEdited: Comment
    
    private let editCommentRepository: EditCommentRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepositoryProtocol
    
    enum CommentEditingError: LocalizedError {
        case noContentError
        
        var errorDescription: String? {
            switch self {
            case .noContentError:
                return "Where are your interesting thoughts?"
            }
        }
    }
    
    init(commentToBeEdited: Comment,
         editCommentRepository: EditCommentRepositoryProtocol,
         mediaUploadRepository: MediaUploadRepositoryProtocol
    ) {
        self.commentToBeEdited = commentToBeEdited
        self.editCommentRepository = editCommentRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func editComment() {
        guard editCommentTask == nil else {
            return
        }
        
        guard !text.isEmpty else {
            error = CommentEditingError.noContentError
            return
        }
        
        editedComment = nil
        
        editCommentTask = Task {
            do {
                editedComment = try await editCommentRepository.editComment(
                    content: text,
                    commentFullname: commentToBeEdited.name,
                    embeddedImages: embeddedImages,
                    giphyGif: giphyGif
                )
            } catch {
                self.error = error
                print("Error editing comment: \(error)")
            }
            
            editCommentTask = nil
        }
    }
    
    func addEmbeddedImage(_ image: UIImage) {
        let embeddedImage = UploadedImage(image: image) {
            try await self.mediaUploadRepository.uploadImage(
                account: AccountViewModel.shared.account,
                image: image, getImageId: true
            )
        }
        embeddedImage.upload()
        embeddedImages.append(embeddedImage)
    }
}
