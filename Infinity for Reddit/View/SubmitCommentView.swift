//
//  SubmitCommentView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-15.
//

import SwiftUI
import MarkdownUI

struct SubmitCommentView: View {
    @StateObject private var submitCommentViewModel: SubmitCommentViewModel
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var toolbarHeight: CGFloat = 0
    
    init(parent: CommentParent) {
        _submitCommentViewModel = StateObject(
            wrappedValue: SubmitCommentViewModel(
                commentParent: parent
            )
        )
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        if let title = submitCommentViewModel.commentParent.title {
                            RowText(title)
                                .primaryText()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                        }
                        
                        if let bodyProcessedMarkdown = submitCommentViewModel.commentParent.bodyProcessedMarkdown {
                            Markdown(bodyProcessedMarkdown)
                                .markdownImageProvider(WebImageProvider(mediaMetadata: submitCommentViewModel.commentParent.mediaMetadata))
                                .font(.system(size: 24))
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 16)
                                .themedPostCommentMarkdown()
                                .markdownLinkHandler { url in
                                    LinkHandler.shared.handle(url: url)
                                }
                        } else if let body = submitCommentViewModel.commentParent.body, !body.isEmpty {
                            Markdown(body)
                                .markdownImageProvider(WebImageProvider(mediaMetadata: submitCommentViewModel.commentParent.mediaMetadata))
                                .font(.system(size: 24))
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 16)
                                .themedPostCommentMarkdown()
                                .markdownLinkHandler { url in
                                    LinkHandler.shared.handle(url: url)
                                }
                        } else {
                            Spacer()
                                .frame(height: 8)
                        }
                        
                        Divider()
                        
                        UserPicker {
                            submitCommentViewModel.selectedAccount = $0
                        }
                        
                        ZStack(alignment: .topLeading) {
                            MarkdownTextField(text: $submitCommentViewModel.text, selectedRange: $selectedRange)
                                .frame(minHeight: 120)
                            
                            if submitCommentViewModel.text.isEmpty {
                                Text("Your interesting thoughts here")
                                    .secondaryText()
                            }
                        }
                        .padding(16)
                    }
                }
                
                Spacer()
                    .frame(height: toolbarHeight)
            }
            
            MarkdownToolbar(
                text: $submitCommentViewModel.text,
                selectedRange: $selectedRange,
                toolbarHeight: $toolbarHeight
            )
        }
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Send Comment")
        .toolbar {
            NavigationBarMenu()
        }
    }
}

enum CommentParent: Hashable {
    case post(parentPost: Post)
    case comment(parentComment: Comment)
    
    var title: String? {
        switch self {
        case .post(let parentPost):
            return parentPost.title
        case .comment:
            return nil
        }
    }
    
    var bodyProcessedMarkdown: MarkdownContent? {
        switch self {
        case .post(let parentPost):
            return parentPost.selftextProcessedMarkdown
        case .comment(let parentComment):
            return parentComment.bodyProcessedMarkdown
        }
    }
    
    var body: String? {
        switch self {
        case .post(let parentPost):
            return parentPost.selftext
        case .comment(let parentComment):
            return parentComment.body
        }
    }
    
    var mediaMetadata: [String: MediaMetadata]? {
        switch self {
        case .post(let parentPost):
            return parentPost.mediaMetadata
        case .comment(let parentComment):
            return parentComment.mediaMetadata
        }
    }
}
