//
//  SubmitCommentRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-21.
//

import Alamofire
import SwiftyJSON
import GiphyUISDK

class SubmitCommentRepository: SubmitCommentRepositoryProtocol {
    enum SubmitCommentRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
        case SendCommentError(String)
    }
    
    func submitComment(accout: Account, content: String, parentFullname: String, depth: Int, embeddedImages: [UploadedImage], giphyGif: GPHMedia?) async throws -> Comment {
        guard !accout.isAnonymous() else {
            throw SubmitCommentRepositoryError.SendCommentError("Please choose an account to submit as.")
        }
        
        guard !content.isEmpty else {
            throw SubmitCommentRepositoryError.SendCommentError("Where are your interesting thoughts?")
        }
        
        let session = SessionProvider.getAccountSpecificSession(account: accout)
        let params: [String : String]
        if embeddedImages.isEmpty && giphyGif == nil {
            params = ["api_type": "json", "return_rtjson": "true", "text": content, "thing_id": parentFullname]
        } else {
            params = ["api_type": "json", "return_rtjson": "true", "richtext_json": RichtextJSONConverter(embeddedImages: embeddedImages, giphyGifId: giphyGif?.id).constructRichtextJSON(markdownString: content), "text": "", "thing_id": parentFullname]
        }
        print(params)
        
        try Task.checkCancellation()
        
        let data = try await session.request(RedditOAuthAPI.sendCommentOrReplyToMessage(params: params))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw SubmitCommentRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit comment.")
        
        let comment = try Comment(fromJson: json)
        if comment.id.isEmpty {
            // This is a work around for checking if JSON parsing failed
            throw(SubmitCommentRepositoryError.SendCommentError("Failed to load your comment."))
        }
        comment.depth = depth
        return comment
    }
}
