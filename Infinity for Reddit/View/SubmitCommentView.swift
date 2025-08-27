//
//  SubmitCommentView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-15.
//

import SwiftUI
import MarkdownUI

struct SubmitCommentView: View {
    @EnvironmentObject private var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var submitCommentViewModel: SubmitCommentViewModel
    
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var toolbarHeight: CGFloat = 0
    @State private var showMarkdownPreview = false
    
    init(parent: CommentParent) {
        _submitCommentViewModel = StateObject(
            wrappedValue: SubmitCommentViewModel(
                commentParent: parent,
                submitCommentRepository: SubmitCommentRepository()
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
                                .frame(minHeight: 300)
                            
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    Task {
                        let sentComment = await submitCommentViewModel.submitComment()
                        if let sentComment = sentComment {
                            await MainActor.run {
                                commentSubmissionShareableViewModel.sentComment = sentComment
                                dismiss()
                            }
                        } else {
                            // Failed to submit this comment
                        }
                    }
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: submitCommentViewModel.text)
        }
    }
}

enum CommentParent: Hashable {
    case post(parentPost: Post)
    case comment(parentComment: Comment)
    
    var parentFullname: String? {
        switch self {
        case .post(let parentPost):
            return parentPost.name
        case .comment(let parentComment):
            return parentComment.name
        }
    }
    
    var childCommentDepth: Int {
        switch self {
        case .post:
            return 0
        case .comment(let parentComment):
            return parentComment.depth + 1
        }
    }
    
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
