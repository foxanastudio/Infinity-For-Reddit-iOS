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

    init(
        backgroundShape: BackgroundShape = Rectangle(),
        action: (() -> Void)? = nil,
        onLongPress: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.backgroundShape = backgroundShape
        self.action = action
        self.content = content
        self.onLongPress = onLongPress
    }

    var body: some View {
        Button {
            action?()
        } label: {
            content()
                .contentShape(backgroundShape)
        }
        .buttonStyle(
            RippleButtonStyle(shape: backgroundShape, onLongPress: onLongPress)
        )
    }
}

struct RippleButtonStyle<S: Shape>: PrimitiveButtonStyle {
    let shape: S
    var animationDuration: Double = 0.15
    
    let onLongPress: (() -> Void)?
    
    @State var isPressed: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                shape
                    .fill(Color.black.opacity(isPressed ? 0.05 : 0))
                    .animation(.easeInOut(duration: 0.15), value: isPressed)
            )
            .onTapGesture {
                configuration.trigger()
            }
            .onLongPressGesture(
                perform: {
                    self.onLongPress?()
                },
                onPressingChanged: { pressing in
                    self.isPressed = pressing
                }
            )
    }
}
