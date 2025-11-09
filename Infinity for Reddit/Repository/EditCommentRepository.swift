//
//  EditCommentRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-31.
//

import GiphyUISDK
import Alamofire
import SwiftyJSON
import MarkdownUI

class EditCommentRepository: EditCommentRepositoryProtocol {
    enum EditCommentRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case EditCommentError(String)
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .EditCommentError(let message):
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
    
    func editComment(content: String, commentFullname: String, mediaMetadataDictionary: [String: MediaMetadata]?, embeddedImages: [UploadedImage], giphyGifId: String?) async throws -> EditCommentResult? {
        guard !content.isEmpty else {
            throw EditCommentRepositoryError.EditCommentError("Where are your interesting thoughts?")
        }
        
        let params: [String : String]
        if (mediaMetadataDictionary == nil || (mediaMetadataDictionary != nil && mediaMetadataDictionary!.isEmpty)) && embeddedImages.isEmpty && giphyGifId == nil {
            params = ["api_type": "json", "text": content, "thing_id": commentFullname]
        } else {
            params = ["api_type": "json", "richtext_json": RichtextJSONConverter(
                mediaMetadataDictionary: mediaMetadataDictionary,
                embeddedImages: embeddedImages,
                giphyGifId: giphyGifId
            ).constructRichtextJSON(markdownString: content), "text": "", "thing_id": commentFullname]
        }
        print(params)
        
        try Task.checkCancellation()
        
        let data = try await session.request(RedditOAuthAPI.editPostOrComment(params: params))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw EditCommentRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to edit comment.")
        
        let thingsJson = json["json"]["data"]["things"].arrayValue
        if !thingsJson.isEmpty {
            let comment = try? Comment(fromJson: thingsJson[0]["data"])
            if let comment {
                if comment.id.isEmpty {
                    // This is a work around for checking if JSON parsing failed
                    return EditCommentResult.content(content: content)
                }
                comment.bodyProcessedMarkdown = MarkdownContent(comment.body)
                return EditCommentResult.comment(comment: comment)
            } else {
                return EditCommentResult.content(content: content)
            }
        } else {
            let comment = try? Comment(fromJson: json)
            if let comment {
                if comment.id.isEmpty {
                    // This is a work around for checking if JSON parsing failed
                    return EditCommentResult.content(content: content)
                }
                comment.bodyProcessedMarkdown = MarkdownContent(comment.body)
                return EditCommentResult.comment(comment: comment)
            } else {
                return EditCommentResult.content(content: content)
            }
        }
    }
}
