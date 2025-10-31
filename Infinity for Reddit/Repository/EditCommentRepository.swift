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
    enum EditCommentRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
        case EditCommentError(String)
    }
    
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    func editComment(content: String, commentFullname: String, embeddedImages: [UploadedImage], giphyGif: GPHMedia?) async throws -> Comment? {
        guard !content.isEmpty else {
            throw EditCommentRepositoryError.EditCommentError("Where are your interesting thoughts?")
        }
        
        let params: [String : String]
        if embeddedImages.isEmpty && giphyGif == nil {
            params = ["api_type": "json", "text": content, "thing_id": commentFullname]
        } else {
            params = ["api_type": "json", "richtext_json": RichtextJSONConverter(embeddedImages: embeddedImages, giphyGif: giphyGif).constructRichtextJSON(markdownString: content), "text": "", "thing_id": commentFullname]
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
            let comment = try Comment(fromJson: thingsJson[0]["data"])
            if comment.id.isEmpty {
                // This is a work around for checking if JSON parsing failed
                throw(EditCommentRepositoryError.EditCommentError("Failed to get your edited comment."))
            }
            comment.bodyProcessedMarkdown = MarkdownContent(comment.body)
            return comment
        }
        
        return nil
    }
}
