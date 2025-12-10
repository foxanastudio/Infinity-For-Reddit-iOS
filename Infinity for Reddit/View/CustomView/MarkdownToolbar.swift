//
//  MarkdownToolbar.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-18.
//

import SwiftUI

struct MarkdownToolbar: View {
    @Binding var text: String
    @Binding var selectedRange: NSRange
    @Binding var toolbarHeight: CGFloat
    
    @FocusState.Binding var focusedField: MarkdownFieldType?
    
    @State private var activeAlert: ActiveAlert? = nil
    @State private var linkText: String = ""
    @State private var linkURL: String = ""
    @State private var headerSize: Float = 1
    
    var enableImageUpload: Bool = false
    var enableGifChooser: Bool = false
    var onImageUpload: (() -> Void)? = nil
    var onChooseGif: (() -> Void)? = nil

    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 4) {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown("**") }) {
                            SwiftUI.Image(systemName: "bold")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown("*") }) {
                            SwiftUI.Image(systemName: "italic")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: {
                            if let range = Range(selectedRange, in: text) {
                                linkText = String(text[range])
                            } else {
                                linkText = ""
                            }
                            
                            linkURL = ""
                            
                            withAnimation(.linear(duration: 0.2)) {
                                activeAlert = .link
                            }
                        }) {
                            SwiftUI.Image(systemName: "link")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown("~~") }) {
                            SwiftUI.Image(systemName: "strikethrough")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown("^(", ")") }) {
                            SwiftUI.Image(systemName: "textformat.superscript")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: {
                            headerSize = 1
                            withAnimation(.linear(duration: 0.2)) {
                                activeAlert = .header
                            }
                        }) {
                            SwiftUI.Image(systemName: "h.circle")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown(left: "1. ") }) {
                            SwiftUI.Image(systemName: "list.number")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown(left: "* ") }) {
                            SwiftUI.Image(systemName: "list.bullet")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown(">!", "!<")}) {
                            SwiftUI.Image(systemName: "exclamationmark.triangle.fill")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown("> ", "\n\n")}) {
                            SwiftUI.Image(systemName: "quote.opening")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        TouchRipple(backgroundShape: Circle(), action: { applyMarkdown("```\n", "\n```\n")}) {
                            SwiftUI.Image(systemName: "chevron.left.forwardslash.chevron.right")
                                .primaryIcon()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        
                        if enableImageUpload {
                            TouchRipple(backgroundShape: Circle(), action: {
                                onImageUpload?()
                            }) {
                                SwiftUI.Image(systemName: "photo")
                                    .primaryIcon()
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        if enableGifChooser {
                            TouchRipple(backgroundShape: Circle(), action: {
                                onChooseGif?()
                            }) {
                                SwiftUI.Image("gif")
                                    .primaryIcon()
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { toolbarHeight = geo.size.height }
                        .onChange(of: geo.size.height) { oldValue, newValue in
                            toolbarHeight = newValue
                        }
                }
            )
        }
        .frame(maxHeight: .infinity)
        .overlay(
            CustomAlert(title: activeAlert?.title ?? "", confirmButtonText: "Insert", isPresented: Binding(
                get: { activeAlert != nil },
                set: { newValue in
                    if !newValue {
                        activeAlert = nil
                    }
                }
            )) {
                switch activeAlert {
                case .link:
                    VStack(spacing: 20) {
                        CustomTextField("Text",
                                        text: $linkText,
                                        singleLine: true,
                                        autocapitalization: .none,
                                        fieldType: .urlText,
                                        focusedField: $focusedField)
                        .submitLabel(.done)
                        
                        CustomTextField("URL",
                                        text: $linkURL,
                                        singleLine: true,
                                        fieldType: .urlLink,
                                        focusedField: $focusedField)
                        .urlTextField()
                        .submitLabel(.done)
                    }
                case .header:
                    VStack(spacing: 4) {
                        CustomUISlider(
                            value: $headerSize,
                            in: 1...6
                        )
                        
                        HStack(spacing: 0) {
                            Text("Large")
                                .primaryText()
                            
                            Spacer()
                            
                            Text("Small")
                                .primaryText()
                        }
                    }
                case nil:
                    EmptyView()
                }
            } onConfirm: {
                if let alert = activeAlert {
                    switch alert {
                    case .link:
                        insertLink()
                    case .header:
                        applyMarkdown(left: String(repeating: "#", count: Int(headerSize)) + " ")
                    }
                }
            }
        )
    }
    
    private func applyMarkdown(_ wrapper: String) {
        guard let range = Range(selectedRange, in: text) else { return }
        
        let selectedText = String(text[range])
        let newText: String
        if selectedRange.length > 0 {
            newText = text.replacingCharacters(in: range, with: "\(wrapper)\(selectedText)\(wrapper)")
            selectedRange = NSRange(location: selectedRange.location,
                                    length: selectedText.count + wrapper.count * 2)
        } else {
            newText = text.inserting("\(wrapper)\(wrapper)", at: selectedRange.location)
            selectedRange = NSRange(location: selectedRange.location + wrapper.count,
                                    length: 0)
        }
        text = newText
    }
    
    private func applyMarkdown(_ left: String, _ right: String) {
        guard let range = Range(selectedRange, in: text) else { return }
        
        let selectedText = String(text[range])
        let newText: String
        if selectedRange.length > 0 {
            newText = text.replacingCharacters(in: range, with: "\(left)\(selectedText)\(right)")
            selectedRange = NSRange(location: selectedRange.location,
                                    length: selectedText.count + left.count + right.count)
        } else {
            newText = text.inserting("\(left)\(right)", at: selectedRange.location)
            selectedRange = NSRange(location: selectedRange.location + left.count,
                                    length: 0)
        }
        text = newText
    }
    
    private func applyMarkdown(left: String) {
        guard let range = Range(selectedRange, in: text) else { return }
        
        let selectedText = String(text[range])
        let newText: String
        if selectedRange.length > 0 {
            newText = text.replacingCharacters(in: range, with: "\(left)\(selectedText)")
            selectedRange = NSRange(location: selectedRange.location,
                                    length: selectedText.count + left.count)
        } else {
            newText = text.inserting("\(left)", at: selectedRange.location)
            selectedRange = NSRange(location: selectedRange.location + left.count,
                                    length: 0)
        }
        text = newText
    }
    
    private func insertLink() {
        guard let range = Range(selectedRange, in: text) else { return }
        
        let linkSyntax = "[\(linkText)](\(linkURL))"
        let newText: String
        if selectedRange.length > 0 {
            newText = text.replacingCharacters(in: range, with: linkSyntax)
            selectedRange = NSRange(location: selectedRange.location,
                                    length: linkSyntax.count)
        } else {
            newText = text.inserting(linkSyntax, at: selectedRange.location)
            selectedRange = NSRange(location: selectedRange.location + linkSyntax.count,
                                    length: 0)
        }
        text = newText
    }
}

private enum ActiveAlert: Identifiable {
    case link, header

    var id: Int {
        hashValue
    }
    
    var title: String {
        switch self {
        case .link: return "Insert Link"
        case .header: return "Insert Header"
        }
    }
}

enum MarkdownFieldType: Hashable {
    case urlText, urlLink
}
