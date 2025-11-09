//
//  EditPostRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-02.
//

protocol EditPostRepositoryProtocol {
    func editPost(content: String, postFullname: String, mediaMetadataDictionary: [String: MediaMetadata]?, embeddedImages: [UploadedImage]) async throws -> EditPostResult
}

enum EditPostResult: Equatable {
    case post(post: Post)
    case content(content: String)
}
