//
//  SnackbarManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-27.
//

import Foundation

class SnackbarManager: ObservableObject {
    @Published var showSnackbar: Bool = true
    @Published var text: String = "asdfasdfasdf asdfasdfasfasdf sdfdsfsdasdfasdf asdfasdfasdf adsfasdfa sdfasdfasf s"
    @Published var actionText: String? = "dismiss"
    @Published var action: (() -> Void)? = nil
    
    func dismiss() {
        showSnackbar = false
        text = ""
        actionText = nil
        action = nil
    }
    
    func showSnackbar(text: String, actionText: String? = nil, action: (() -> Void)? = nil) {
        self.text = text
        self.actionText = actionText
        self.action = action
        self.showSnackbar = true
    }
}
