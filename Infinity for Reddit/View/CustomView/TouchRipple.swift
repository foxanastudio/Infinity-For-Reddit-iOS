//
//  TouchRipple.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-17.
//

import SwiftUI

struct TouchRipple<Content: View, BackgroundShape: Shape>: View {

    let backgroundShape: BackgroundShape
    let action: (() -> Void)?
    let onLongPress: (() -> Void)?
    let content: () -> Content
    let allowTapAfterLongPress: Bool
    
    @State private var didLongPress = false

    init(
        backgroundShape: BackgroundShape = Rectangle(),
        action: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        allowTapAfterLongPress: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.backgroundShape = backgroundShape
        self.action = action
        self.content = content
        self.onLongPress = onLongPress
        self.allowTapAfterLongPress = allowTapAfterLongPress
    }

    var body: some View {
        Button {
            if allowTapAfterLongPress || !didLongPress {
                action?()
            }
            didLongPress = false
        } label: {
            content()
                .contentShape(backgroundShape)
        }
        .buttonStyle(
            RippleButtonStyle(shape: backgroundShape)
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    if !allowTapAfterLongPress {
                        didLongPress = true
                    }
                    onLongPress?()
                }
        )
    }
}

struct RippleButtonStyle<S: Shape>: ButtonStyle {

    let shape: S

    var pressedColor: Color = Color.black.opacity(0.08)
    var animationDuration: Double = 0.22

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                shape
                    .fill(pressedColor)
                    .opacity(configuration.isPressed ? 1 : 0)
            )
            .animation(
                .easeOut(duration: animationDuration),
                value: configuration.isPressed
            )
    }
}
