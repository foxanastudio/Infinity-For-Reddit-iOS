//
//  EditPostViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-02.
//

import Foundation
import MarkdownUI
import SwiftUI
import GiphyUISDK

@MainActor
class EditPostViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var embeddedImages: [UploadedImage] = []
    @Published var editPostTask: Task<Void, Error>?
    @Published var editPostResult: EditPostResult?
    @Published var error: Error? = nil
    
    let postToBeEdited: Post
    
    private let editPostRepository: EditPostRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepositoryProtocol
    
    enum PostEditingError: LocalizedError {
        case noContentError
        
        var errorDescription: String? {
            switch self {
            case .noContentError:
                return "Where are your interesting thoughts?"
            }
        }
    }
    
    init(postToBeEdited: Post,
         editPostRepository: EditPostRepositoryProtocol,
         mediaUploadRepository: MediaUploadRepositoryProtocol
    ) {
        self.text = postToBeEdited.selftext
        self.postToBeEdited = postToBeEdited
        self.editPostRepository = editPostRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func editPost() {
        guard editPostTask == nil else {
            return
        }
        
        guard !text.isEmpty else {
            error = PostEditingError.noContentError
            return
        }
        
        editPostResult = nil
        
        editPostTask = Task {
            do {
                editPostResult = try await editPostRepository.editPost(
                    content: text,
                    postFullname: postToBeEdited.name,
                    mediaMetadataDictionary: postToBeEdited.mediaMetadata,
                    embeddedImages: embeddedImages
                )
            } catch {
                self.error = error
                print("Error editing post: \(error)")
            }
            
            editPostTask = nil
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
