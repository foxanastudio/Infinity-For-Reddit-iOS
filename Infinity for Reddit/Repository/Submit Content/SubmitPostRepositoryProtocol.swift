//
//  SubmitPostRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-13.
//

import UIKit

protocol SubmitPostRepositoryProtocol {
    // Returns the ID of the submitted post
    func submitTextPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool,
        embeddedImages: [UploadedImage]
    ) async throws -> String
    
    func submitImagePost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        imageUrlString: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws
    
    func submitGifPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        gifUrlString: String,
        posterUrlString: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws
    
    func submitLinkPost(
        account: Account,
        subredditName: String,
        title: String,
        urlString: String,
        content: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws -> String
    
    func submitGalleryPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        galleryImages: [UploadedImage],
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws -> String
    
    func submitVideoPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        videoUrlString: String,
        posterUrlString: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws
    
    func submitPollPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        options: [String],
        duration: Int,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool,
        embeddedImages: [UploadedImage]
    ) async throws -> String
    
    func crosspost(
        account: Account,
        subredditName: String,
        title: String,
        crosspostFullname: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws -> String
}
