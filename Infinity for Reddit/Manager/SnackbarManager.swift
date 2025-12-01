//
//  SnackbarManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-27.
//

import Foundation
import SwiftUI

@MainActor
class SnackbarManager: ObservableObject {
    @Published var showSnackbar: Bool = false
    @Published var canDismissByGesture: Bool = true
    @Published var text: String = ""
    @Published var actionText: String? = nil
    @Published var action: (() -> Void)? = nil
    
    var autoDismiss: Bool = true
    
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
    
    func showSnackbar(
        _ snackbarMessage: SnackbarMessage,
        actionText: String? = nil,
        autoDismiss: Bool = true,
        canDismissByGesture: Bool = true,
        action: (() -> Void)? = nil
    ) {
        snackbarTask?.cancel()
        
        self.text = snackbarMessage.text
        self.autoDismiss = autoDismiss
        self.canDismissByGesture = canDismissByGesture
        self.actionText = actionText
        self.action = action
        withAnimation {
            self.showSnackbar = true
        }
        
        if autoDismiss {
            snackbarTask = Task {
                try? await Task.sleep(for: .seconds(2))
                
                do {
                    try Task.checkCancellation()
                    dismiss()
                } catch {
                    // Ignore
                }
                snackbarTask = nil
            }
        }
    }
    
    func dismissIfIndefinite() {
        if !autoDismiss {
            dismiss()
        }
    }
}
