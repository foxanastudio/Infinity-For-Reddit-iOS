//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI
import Kingfisher

struct TestView: View {
    var body: some View {
        VStack {
            KFAnimatedImage(URL(string: "https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExaHo0bm5ieG81YWw1ZWd0NzgwaXFscDRjc3JreTlnd2s4cGFkZ2hiYyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/2D8g2rXcWx1DO/giphy.gif"))
                .configure { view in
                    view.contentMode = .scaleAspectFit   // .resizable().scaledToFit()
                }
                .frame(width: 200, height: 200)

            KFAnimatedImage(URL(string: "https://preview.redd.it/mymedia-2-0-released-open-source-app-written-purely-in-v0-lu431bo885sf1.png?width=1080&crop=smart&auto=webp&s=5b8e2d5f1dcf6b0462b6750343e6dfa6c3402f09"))
                .configure { view in
                    view.contentMode = .scaleAspectFill  // .resizable()
                    view.clipsToBounds = true
                }
                .frame(width: 200, height: 200)
        }
    }
}

//struct TestView: View {
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("INTERFACE FONT MODIFIERS")
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .foregroundColor(.secondary)
//
//                    Divider()
//
//                    Text("PrimaryTextViewModifier")
//                        .modifier(PrimaryTextViewModifier())
//
//                    Text("SecondaryTextViewModifier")
//                        .modifier(SecondaryTextViewModifier())
//
//                    Text("ButtonTextViewModifier")
//                        .modifier(ButtonTextViewModifier())
//
//                    Text("NavigationBarPrimaryTextViewModifier")
//                        .modifier(NavigationBarPrimaryTextViewModifier())
//
//                    Button("NavigationBarButtonViewModifier") {
//                    }
//                    .modifier(NavigationBarButtonViewModifier())
//
//                    Text("PostInfoTextViewModifier (time, score, etc.)")
//                        .modifier(PostInfoTextViewModifier())
//
//                    Text("CommentInfoTextViewModifier (time, score, etc.)")
//                        .modifier(CommentInfoTextViewModifier())
//
//                    Text("UsernameTextViewModifier")
//                        .modifier(UsernameTextViewModifier())
//
//                    Text("UsernameOnPostTextViewModifier (requires Post)")
//                        .customFont()
//                        .italic()
//
//                    Text("SubredditTextViewModifier (r/subreddit - uses Interface Font)")
//                        .modifier(SubredditTextViewModifier())
//
//                    Text("ListSectionHeaderViewModifier")
//                        .modifier(ListSectionHeaderViewModifier())
//
//                    Text("GalleryIndexIndicatorViewModifier")
//                        .modifier(GalleryIndexIndicatorViewModifier())
//
//                    Text("ColorAccentTextViewModifier")
//                        .modifier(ColorAccentTextViewModifier())
//
//                    Text("PositiveTextButtonViewModifier")
//                        .modifier(PositiveTextButtonViewModifier())
//
//                    Text("WarningTextButtonViewModifier")
//                        .modifier(WarningTextButtonViewModifier())
//
//                    Text("NeutralTextButtonViewModifier")
//                        .modifier(NeutralTextButtonViewModifier())
//
//                    Text("MarkdownViewModifier (general)")
//                        .customFont()
//                }
//
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("POST TITLE FONT MODIFIER")
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .foregroundColor(.secondary)
//
//                    Divider()
//
//                    Text("PostTitleTextViewModifier - This is a Sample Post Title")
//                        .modifier(PostTitleTextViewModifier())
//                }
//
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("CONTENT FONT MODIFIERS")
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .foregroundColor(.secondary)
//
//                    Divider()
//
//                    Text("PostContentTextViewModifier - This is the post body text content that users write when creating a text post.")
//                        .postContent()
//
//                    Text("CommentTextViewModifier - Comment text (uses Content Font)")
//                        .commentText()
//
//                    Text("PostContentMarkdownViewModifier (for markdown in posts)")
//                        .themedPostCommentMarkdown()
//
//                    Text("CommentMarkdownViewModifier (for markdown in comments)")
//                        .themedPostCommentMarkdown()
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("Font Modifier Test")
//    }
//}
