//
//  EditCommentRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-31.
//

import GiphyUISDK

protocol EditCommentRepositoryProtocol {
    func editComment(content: String, commentFullname: String, embeddedImages: [UploadedImage], giphyGif: GPHMedia?) async throws -> Comment?
}
