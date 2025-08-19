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
    
    init(parent: CommentParent) {
        _submitCommentViewModel = StateObject(
            wrappedValue: SubmitCommentViewModel(
                commentParent: parent
            )
        )
    }
    
    var body: some View {
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
                    } else if let body = submitCommentViewModel.commentParent.body {
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
            
            MarkdownToolbar(
                onBold: { applyMarkdown("**") },
                onItalic: { applyMarkdown("_") },
                onLink: { insertLink() }
            )
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Send Comment")
        .toolbar {
            NavigationBarMenu()
        }
    }
    
    private func applyMarkdown(_ wrapper: String) {
        guard let range = Range(selectedRange, in: submitCommentViewModel.text) else { return }
        
        let selectedText = String(submitCommentViewModel.text[range])
        let newText: String
        if selectedRange.length > 0 {
            newText = submitCommentViewModel.text.replacingCharacters(in: range, with: "\(wrapper)\(selectedText)\(wrapper)")
            selectedRange = NSRange(location: selectedRange.location,
                                    length: selectedText.count + wrapper.count * 2)
        } else {
            newText = submitCommentViewModel.text.inserting("\(wrapper)\(wrapper)", at: selectedRange.location)
            selectedRange = NSRange(location: selectedRange.location + wrapper.count,
                                    length: 0)
        }
        submitCommentViewModel.text = newText
    }
    
    private func insertLink() {
        let linkSyntax = "[text](url)"
        submitCommentViewModel.text = submitCommentViewModel.text.inserting(linkSyntax, at: selectedRange.location)
        selectedRange = NSRange(location: selectedRange.location + 1, length: 4)
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
