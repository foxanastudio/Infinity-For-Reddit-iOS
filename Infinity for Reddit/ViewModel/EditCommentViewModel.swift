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
    @Published var giphyGifId: String?
    @Published var editCommentTask: Task<Void, Error>?
    @Published var editCommentResult: EditCommentResult?
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
        self.text = commentToBeEdited.body
        self.commentToBeEdited = commentToBeEdited
        self.editCommentRepository = editCommentRepository
        self.mediaUploadRepository = mediaUploadRepository
        
        commentToBeEdited.mediaMetadata?.forEach { entry in
            if MediaMetadata.gifType == entry.value.e {
                giphyGifId = entry.key
            }
        }
    }
    
    func editComment() {
        guard editCommentTask == nil else {
            return
        }
        
        guard !text.isEmpty else {
            error = CommentEditingError.noContentError
            return
        }
        
        editCommentResult = nil
        
        editCommentTask = Task {
            do {
                editCommentResult = try await editCommentRepository.editComment(
                    content: text,
                    commentFullname: commentToBeEdited.name,
                    mediaMetadataDictionary: commentToBeEdited.mediaMetadata,
                    embeddedImages: embeddedImages,
                    giphyGifId: giphyGifId
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
