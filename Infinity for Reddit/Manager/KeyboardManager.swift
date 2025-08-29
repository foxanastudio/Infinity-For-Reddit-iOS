//
//  KeyboardManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-28.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class KeyboardManager: ObservableObject {
    @Published var isVisible: Bool = false
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] _ in
                withAnimation {
                    self?.isVisible = true
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                withAnimation {
                    self?.isVisible = false
                }
            }
            .store(in: &cancellables)
    }
}
