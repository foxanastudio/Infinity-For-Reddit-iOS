//
//  PostShareSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-26.
//

import SwiftUI
import UniformTypeIdentifiers

struct PostShareSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let post: Post
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                RowText(post.postUrlString)
                    .secondaryText(.f13)
                    .padding(16)
                
                ShareLinkEntry(urlString: post.postUrlString, text: "Share Post Link")
                
                IconTextButton(startIconUrl: "document.on.document", text: "Copy Post Link") {
                    Utils.copyText(post.postUrlString)
                    dismiss()
                }
                
//                IconTextButton(startIconUrl: "text.bubble", text: "Share as Image") {
//                    onComment()
//                    dismiss()
//                }
                
                if let mediaShareUrlString = post.getMediaShareUrlString() {
                    RowText(mediaShareUrlString)
                        .secondaryText(.f13)
                        .padding(16)
                    
                    ShareLinkEntry(urlString: mediaShareUrlString, text: "Share Media Link")
                    
                    IconTextButton(startIconUrl: "document.on.document", text: "Copy Media Link") {
                        Utils.copyText(mediaShareUrlString)
                        dismiss()
                    }
                }
            }
            .padding(.top, 24)
        }
    }
    
    private struct ShareLinkEntry: View {
        let urlString: String
        let text: String
        
        var body: some View {
            ShareLink(item: urlString) {
                HStack(spacing: 0) {
                    SwiftUI.Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .primaryIcon()
                    
                    Spacer()
                        .frame(width: 32)
                    
                    Text(text)
                        .primaryText()
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(16)
            }
            .buttonStyle(.borderless)
            .contentShape(Rectangle())
        }
    }
}
