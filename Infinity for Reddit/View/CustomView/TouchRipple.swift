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

    @State private var validTouch: Bool = true
    @State private var isPressed = false
    @State private var dragStartLocation: CGPoint? = nil
    @State private var excludedViews: [CGRect] = []
    
    let maxTapMovement: CGFloat = 10
    
    private let id = UUID()
    
    init(backgroundShape: BackgroundShape = Rectangle(), action: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.backgroundShape = backgroundShape
        self.action = action
        self.content = content
    }

    var body: some View {
        content()
            .environment(\.touchRippleId, id)
            .overlay(
                backgroundShape
                    .fill(Color.black.opacity(isPressed ? 0.05 : 0))
                    .animation(.easeInOut(duration: 0.15), value: isPressed)
            )
            .coordinateSpace(name: id.uuidString)
            .onPreferenceChange(ExcludedViewsKey.self) { dict in
                excludedViews = dict[id] ?? []
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if dragStartLocation == nil {
                            dragStartLocation = value.startLocation
                        }
                        
                        guard let start = dragStartLocation else { return }
                        let distance = hypot(value.location.x - start.x, value.location.y - start.y)
                        
                        if distance <= maxTapMovement && validTouch && isOutsideExcludedViews(value.location) {
                            if !isPressed {
                                isPressed = true
                            }
                        } else {
                            validTouch = false
                            if isPressed {
                                isPressed = false
                            }
                        }
                    }
                    .onEnded { value in
                        defer {
                            dragStartLocation = nil
                            isPressed = false
                            validTouch = true
                        }

                        guard let start = dragStartLocation, validTouch else { return }
                        let dragDistance = hypot(value.location.x - start.x, value.location.y - start.y)
                        
                        if dragDistance <= maxTapMovement {
                            action?()
                        }
                    },
                including: .subviews
            )
    }
    
    private func isOutsideExcludedViews(_ point: CGPoint) -> Bool {
        return !excludedViews.contains { $0.contains(point) }
    }
}

private struct TouchRippleId: EnvironmentKey {
    static var defaultValue: UUID? = nil
}

extension EnvironmentValues {
    var touchRippleId: UUID? {
        get { self[TouchRippleId.self] }
        set { self[TouchRippleId.self] = newValue }
    }
}

private struct ExcludedViewsKey: PreferenceKey {
    static var defaultValue: [UUID: [CGRect]] = [:]
    static func reduce(value: inout [UUID: [CGRect]], nextValue: () -> [UUID: [CGRect]]) {
        for (id, frames) in nextValue() {
            value[id, default: []].append(contentsOf: frames)
        }
    }
}

private struct ExcludeFromTouchRippleViewModifier: ViewModifier {
    @Environment(\.touchRippleId) private var touchRippleId: UUID?

    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo in
                if let id = touchRippleId {
                    let frame = geo.frame(in: .named(id.uuidString))
                    Color.clear.preference(
                        key: ExcludedViewsKey.self,
                        value: [id: [frame]]
                    )
                } else {
                    Color.clear
                }
            }
        )
    }
}

extension View {
    func excludeFromTouchRipple() -> some View {
        modifier(ExcludeFromTouchRippleViewModifier())
    }
}
