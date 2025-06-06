//
// SubredditAboutView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-06

import SwiftUI
import MarkdownUI

struct SubredditAboutView: View {
    let description: String?

    var body: some View {
        ScrollView{
            VStack(spacing: 0) {
                if let desc = description, !desc.isEmpty {
                    Markdown(desc)
                        .themedMarkdown()
                        .padding(0)
                }
            }
        }
    }
}
