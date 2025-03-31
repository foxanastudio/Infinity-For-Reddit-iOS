//
//  CommentViewCard.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-17.
//

import SwiftUI
import SDWebImageSwiftUI
import MarkdownUI

struct CommentViewCard: View {
    @StateObject var commentViewModel: CommentViewModel
    
    let formatter = DateFormatter()
    private let isInPostDetails: Bool
    
    init(account: Account, comment: Comment, isInPostDetails: Bool) {
        formatter.dateFormat = "y-MM-dd H:mm"
        self.isInPostDetails = isInPostDetails
        _commentViewModel = StateObject(wrappedValue: CommentViewModel(account: account, comment: comment, commentRepository: CommentRepository()))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    if !isInPostDetails {
                        Text(commentViewModel.comment.subredditNamePrefixed)
                            .subreddit()
                    }
                    
                    Text("u/\(commentViewModel.comment.author)")
                        .username()
                }
                
                Spacer()
                
                Text(
                    formatter.string(from: Date(timeIntervalSince1970: TimeInterval(commentViewModel.comment.createdUtc)))
                )
                .secondaryText()
            }
            .padding(.vertical, 8)
                    
            Group {
                if commentViewModel.comment.bodyProcessedMarkdown != nil {
                    Markdown(commentViewModel.comment.bodyProcessedMarkdown!)
                        .markdownImageProvider(WebImageProvider(mediaMetadata: commentViewModel.comment.mediaMetadata))
                        .font(.system(size: 24))
                        .padding(.bottom, 8)
                        .themedMarkdown()
                        .id(commentViewModel.comment.id)
                } else {
                    Markdown(commentViewModel.comment.body)
                        .markdownImageProvider(WebImageProvider(mediaMetadata: commentViewModel.comment.mediaMetadata))
                        .font(.system(size: 24))
                        .padding(.bottom, 8)
                        .themedMarkdown()
                        .id(commentViewModel.comment.id)
                }
            }
            
            HStack(alignment: .center) {
                Button(action: {
                    commentViewModel.voteComment(vote: 1)
                }) {
                    SwiftUI.Image(commentViewModel.comment.likes == 1 ? "upvoted" : "upvote")
                        .commentIconTemplateRendering()
                        .commentUpvoteIcon(isUpvoted: commentViewModel.comment.likes == 1)
                }
                .buttonStyle(.borderless)
                
                Text(String(commentViewModel.comment.score + commentViewModel.comment.likes))
                    .frame(width: 50, alignment: .center)
                    .commentInfo()
                
                Button(action: {
                    commentViewModel.voteComment(vote: -1)
                }) {
                    SwiftUI.Image(commentViewModel.comment.likes == -1 ? "downvoted" : "downvote")
                        .commentIconTemplateRendering()
                        .commentDownvoteIcon(isDownvoted: commentViewModel.comment.likes == -1)
                }
                .padding(.trailing, 16)
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button {
                    
                } label: {
                    SwiftUI.Image(systemName: "square.and.arrow.up")
                        .commentIconTemplateRendering()
                        .commentIcon()
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 8)
            
            Divider()
        }
        .padding(.vertical, -11)
    }
}
