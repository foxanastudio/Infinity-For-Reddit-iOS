//
//  PostOptionsSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-25.
//

import SwiftUI

struct PostOptionsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let post: Post
    
    var onComment: () -> Void
    var onShare: () -> Void
    var onAddToPostFilter: () -> Void
    var onToggleHidePost: () -> Void
    var onCrosspost: () -> Void
    var onDownloadMedia: () -> Void
    var onDownloadAllGalleryMedia: () -> Void
    var onReport: () -> Void
    var onModeration: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                IconTextButton(startIconUrl: "text.bubble", text: "Comment") {
                    onComment()
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "square.and.arrow.up", text: "Share") {
                    onShare()
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "line.3.horizontal.decrease.circle", text: "Add to Post Filter") {
                    onAddToPostFilter()
                    dismiss()
                }

                IconTextButton(startIconUrl: post.hidden ? "eye" :"eye.slash", text: post.hidden ? "Unhide" : "Hide") {
                    onToggleHidePost()
                    dismiss()
                }
                
                if post.isCrosspostable {
                    IconTextButton(startIconUrl: "arrow.2.squarepath", text: "Crosspost") {
                        onCrosspost()
                        dismiss()
                    }
                }
                
                if let downloadText = post.postType.downloadText {
                    IconTextButton(startIconUrl: "square.and.arrow.down", text: downloadText) {
                        onDownloadMedia()
                        dismiss()
                    }
                }
                
                if post.postType == .gallery {
                    IconTextButton(startIconUrl: "square.and.arrow.down.on.square", text: "Download All Gallery Media") {
                        onDownloadAllGalleryMedia()
                        dismiss()
                    }
                }
                
                IconTextButton(startIconUrl: "flag", text: "Report") {
                    onReport()
                    dismiss()
                }
                
                if post.canModPost {
                    IconTextButton(startIconUrl: "checkmark.shield.fill", text: "Moderate") {
                        onModeration()
                        dismiss()
                    }
                }
            }
            .padding(.top, 24)
        }
    }
}

private extension Post.PostType {
    var downloadText: String? {
        switch self {
        case .image, .imageWithUrlPreview:
            return "Download Image"
        case .gif:
            return "Download Gif"
        case .redditVideo, .video, .imgurVideo, .redgifs, .streamable:
            return "Download Video"
        default:
            return nil
        }
    }
}
