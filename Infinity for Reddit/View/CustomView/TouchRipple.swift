//
//  TouchRipple.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-17.
//

import SwiftUI

struct TouchRipple<Content: View, BackgroundShape: Shape>: View {
    let backgroundShape: BackgroundShape
    var action: (() -> Void)? = nil
    let content: () -> Content

    @GestureState private var isPressed = false

    var body: some View {
        content()
            .overlay(
                backgroundShape
                    .fill(Color.black.opacity(isPressed ? 0.05 : 0))
                    .animation(.easeInOut(duration: 0.15), value: isPressed)
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { value, state, _ in
                        state = true
                    }
                    .onEnded { _ in
                        action?()
                    }
            )
    }
}
