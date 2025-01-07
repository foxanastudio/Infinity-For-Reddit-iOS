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
    
    init(account: Account, comment: Comment) {
        formatter.dateFormat = "y-MM-dd H:mm"
        _commentViewModel = StateObject(wrappedValue: CommentViewModel(account: account, comment: comment))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(commentViewModel.comment.subredditNamePrefixed)
                    Text("u/\(commentViewModel.comment.author)")
                }
                
                Spacer()
                
                Text(
                    formatter.string(from: Date(timeIntervalSince1970: TimeInterval(commentViewModel.comment.createdUtc)))
                )
            }
            .padding(.vertical, 8)
            
            Markdown(commentViewModel.comment.body)
                .markdownImageProvider(.webImage)
                .font(.system(size: 24))
                .padding(.bottom, 8)
            
            HStack(alignment: .center) {
                Button(action: {
                    commentViewModel.voteComment(vote: 1)
                    commentViewModel.comment.likes = 1
                }) {
                    SwiftUI.Image(commentViewModel.comment.likes == 1 ? "upvoted" : "upvote")
                }
                .buttonStyle(.borderless)
                
                Text(String(commentViewModel.comment.score))
                    .frame(width: 50, alignment: .center)
                
                Button(action: {
                    commentViewModel.voteComment(vote: -1)
                }) {
                    SwiftUI.Image(commentViewModel.comment.likes == -1 ? "downvoted" : "downvote")
                }
                .padding(.trailing, 16)
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button {
                    
                } label: {
                    SwiftUI.Image(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 8)
        }
    }
}
