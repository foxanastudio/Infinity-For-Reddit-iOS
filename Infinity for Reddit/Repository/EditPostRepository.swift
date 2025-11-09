//
//  EditPostRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-02.
//

import GiphyUISDK
import Alamofire
import SwiftyJSON
import MarkdownUI

class EditPostRepository: EditPostRepositoryProtocol {
    enum EditPostRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case EditPostError(String)
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .EditPostError(let message):
                return message
            }
        }
    }
    
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    func editPost(content: String, postFullname: String, mediaMetadataDictionary: [String: MediaMetadata]?, embeddedImages: [UploadedImage]) async throws -> EditPostResult {
        guard !content.isEmpty else {
            throw EditPostRepositoryError.EditPostError("Where are your interesting thoughts?")
        }
        
        let params: [String : String]
        if (mediaMetadataDictionary == nil || (mediaMetadataDictionary != nil && mediaMetadataDictionary!.isEmpty)) && embeddedImages.isEmpty {
            params = ["api_type": "json", "text": content, "thing_id": postFullname]
        } else {
            params = ["api_type": "json", "richtext_json": RichtextJSONConverter(
                mediaMetadataDictionary: mediaMetadataDictionary,
                embeddedImages: embeddedImages
            ).constructRichtextJSON(markdownString: content), "text": "", "thing_id": postFullname]
        }
        print(params)
        
        try Task.checkCancellation()
        
        let data = try await session.request(RedditOAuthAPI.editPostOrComment(params: params))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw EditPostRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to edit comment.")
        
        let thingsJson = json["json"]["data"]["things"].arrayValue
        if !thingsJson.isEmpty {
            let post = try? Post(fromJson: thingsJson[0]["data"])
            if let post {
                if post.id.isEmpty {
                    // This is a work around for checking if JSON parsing failed
                    return EditPostResult.content(content: content)
                }
                post.selftextProcessedMarkdown = MarkdownContent(post.selftext)
                return EditPostResult.post(post: post)
            } else {
                return EditPostResult.content(content: content)
            }
        } else {
            let post = try? Post(fromJson: json)
            if let post {
                if post.id.isEmpty {
                    // This is a work around for checking if JSON parsing failed
                    return EditPostResult.content(content: content)
                }
                post.selftextProcessedMarkdown = MarkdownContent(post.selftext)
                return EditPostResult.post(post: post)
            } else {
                return EditPostResult.content(content: content)
            }
        }
    }
}
