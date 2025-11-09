//
//  EditCommentRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-31.
//

import GiphyUISDK

protocol EditCommentRepositoryProtocol {
    func editComment(content: String, commentFullname: String, mediaMetadataDictionary: [String: MediaMetadata]?, embeddedImages: [UploadedImage], giphyGifId: String?) async throws -> EditCommentResult?
}

enum EditCommentResult: Equatable {
    case comment(comment: Comment)
    case content(content: String)
}
