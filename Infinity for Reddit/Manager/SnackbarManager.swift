//
//  SnackbarManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-27.
//

import Foundation
import SwiftUI

class SnackbarManager: ObservableObject {
    @Published var showSnackbar: Bool = false
    @Published var text: String = ""
    @Published var actionText: String? = nil
    @Published var action: (() -> Void)? = nil
    
    var snackbarTask: Task<Void, Never>?
    
    func dismiss() {
        snackbarTask?.cancel()
        
        withAnimation {
            showSnackbar = false
        } completion: {
            self.text = ""
            self.actionText = nil
            self.action = nil
        }
    }
    
    func showSnackbar(text: String, actionText: String? = nil, autoDismiss: Bool = true, action: (() -> Void)? = nil) {
        snackbarTask?.cancel()
        
        self.text = text
        self.actionText = actionText
        self.action = action
        withAnimation {
            self.showSnackbar = true
        }
        
        if autoDismiss {
            snackbarTask = Task {
                try? await Task.sleep(for: .seconds(2))
                
                try? Task.checkCancellation()
                
                await MainActor.run {
                    dismiss()
                    snackbarTask = nil
                }
            }
        }
    }
}
