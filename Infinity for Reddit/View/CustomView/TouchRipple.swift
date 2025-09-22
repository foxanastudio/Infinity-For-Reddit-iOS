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
            .modify {
                if #available(iOS 26, *) {
                    $0.gesture(
                        SimultaneousGesture(
                            onBegan: {
                                print("Long Press Began")
                            },
                            onChanged: { recognizer in
                                let location = recognizer.location(in: recognizer.view)
                                if dragStartLocation == nil {
                                    dragStartLocation = location
                                }
                                
                                guard let start = dragStartLocation else { return }
                                
                                let distance = hypot(location.x - start.x, location.y - start.y)
                                
                                if distance <= maxTapMovement && validTouch && isOutsideExcludedViews(location) {
                                    if !isPressed {
                                        isPressed = true
                                    }
                                } else {
                                    validTouch = false
                                    if isPressed {
                                        isPressed = false
                                    }
                                }
                            },
                            onEnded: { recognizer in
                                defer {
                                    dragStartLocation = nil
                                    isPressed = false
                                    validTouch = true
                                }

                                guard let start = dragStartLocation, validTouch else { return }
                                let location = recognizer.location(in: recognizer.view)
                                let dragDistance = hypot(location.x - start.x, location.y - start.y)
                                
                                if dragDistance <= maxTapMovement {
                                    action?()
                                }
                            }
                        )
                    )
                } else {
                    $0.simultaneousGesture(
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
                            }
                    )
                }
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
                    }
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

struct SimultaneousGesture: UIGestureRecognizerRepresentable {
    let onBegan: () -> Void
    let onChanged: (UILongPressGestureRecognizer) -> Void
    let onEnded: (UILongPressGestureRecognizer) -> Void

    init(onBegan: @escaping () -> Void = {},
         onChanged: @escaping (UILongPressGestureRecognizer) -> Void,
         onEnded: @escaping (UILongPressGestureRecognizer) -> Void = {_ in }) {
        self.onBegan = onBegan
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let gestureRecognizer = UILongPressGestureRecognizer()
        
        // Configure the long press gesture
        gestureRecognizer.minimumPressDuration = 0.0 // Immediate recognition
        gestureRecognizer.allowableMovement = CGFloat.greatestFiniteMagnitude // Allow movement
        gestureRecognizer.delegate = context.coordinator
        
        return gestureRecognizer
    }
    
    func handleUIGestureRecognizerAction(_ gestureRecognizer: UILongPressGestureRecognizer, context: Context) {
        switch gestureRecognizer.state {
        case .began:
            onBegan()
            onChanged(gestureRecognizer)
        case .changed:
            onChanged(gestureRecognizer)
        case .ended, .cancelled:
            onEnded(gestureRecognizer)
        default:
            break
        }
    }
    
    func updateUIGestureRecognizer(_ gestureRecognizer: UILongPressGestureRecognizer, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        // Key method for simultaneous recognition with ScrollView
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        // Optional: Add conditions to fail early if needed
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            // Add any conditions here to fail early if the gesture is invalid
            return true
        }
    }
}

extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}
