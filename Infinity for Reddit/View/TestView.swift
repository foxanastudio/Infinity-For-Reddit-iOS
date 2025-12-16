//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        List(1...10, id: \.self) { index in
            TouchRipple {
                print("Tapped row \(index)")
            } content: {
                Text("Row \(index)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .listPlainItemNoInsets()
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .navigationTitle("Ripple Demo")
    }
}

struct SimpleTouchRipple<Content: View, BackgroundShape: Shape>: View {

    let backgroundShape: BackgroundShape
    let action: (() -> Void)?
    let content: () -> Content

    init(
        backgroundShape: BackgroundShape = Rectangle(),
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.backgroundShape = backgroundShape
        self.action = action
        self.content = content
    }

    var body: some View {
        Button {
            action?()
        } label: {
            content()
                .contentShape(backgroundShape)
        }
        .buttonStyle(
            SimpleRippleButtonStyle(shape: backgroundShape)
        )
    }
}

struct SimpleRippleButtonStyle<S: Shape>: ButtonStyle {

    let shape: S

    var pressedColor: Color = Color.black.opacity(0.08)

    var animationDuration: Double = 0.16

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
