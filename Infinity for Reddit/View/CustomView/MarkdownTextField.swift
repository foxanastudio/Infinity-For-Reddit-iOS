//
//  MarkdownTextField.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-18.
//

import SwiftUI

struct MarkdownTextField: UIViewRepresentable {
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    @Binding var text: String
    @Binding var selectedRange: NSRange
    @Binding var canFocus: Bool

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkdownTextField

        init(parent: MarkdownTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            let text = textView.text
            DispatchQueue.main.async {
                self.parent.text = text ?? ""
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            let range = textView.selectedRange
            DispatchQueue.main.async {
                self.parent.selectedRange = range
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = true
        textView.delegate = context.coordinator
        textView.borderStyle = .none
        textView.tintColor = UIColor(Color(hex: customThemeViewModel.currentCustomTheme.colorPrimaryLightTheme))
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if uiView.selectedRange != selectedRange {
            uiView.selectedRange = selectedRange
        }
        
        DispatchQueue.main.async {
            if uiView.isFirstResponder && !canFocus {
                uiView.resignFirstResponder()
                self.canFocus = true
            }
        }
    }
}

extension String {
    func inserting(_ new: String, at index: Int) -> String {
        let i = self.index(self.startIndex, offsetBy: index)
        return String(self[..<i]) + new + String(self[i...])
    }
}
