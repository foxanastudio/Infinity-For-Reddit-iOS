//
//  MediaGestureViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-07.
//

import SwiftUI

struct MediaGestureViewModifier: ViewModifier {
    let minZoomScale: CGFloat
    let doubleTapZoomScale: CGFloat
    let outOfBoundsColor: Color
    
    @State private var lastTransform: CGAffineTransform = .identity
    @State private var transform: CGAffineTransform = .identity
    @State private var containerSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero
    @State private var dismissStarted: Bool = false
    
    let onDragEnded: (CGAffineTransform) -> Bool
    let onStartDismiss: () -> Void
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            ZStack {
                outOfBoundsColor
                    .opacity(opacityForBackground(maxYDistance: 300))
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea()
                
                content
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    contentSize = proxy.size
                                }
                                .onChange(of: proxy.size) { _, newValue in
                                    contentSize = newValue
                                }
                        }
                    }
                    .animatableTransformEffect(transform)
                    .gesture(dragGesture, isEnabled: !dismissStarted)
                    .modify { view in
                        if #available(iOS 17.0, *) {
                            view.gesture(magnificationGesture, isEnabled: !dismissStarted)
                        } else {
                            view.gesture(oldMagnificationGesture, isEnabled: !dismissStarted)
                        }
                    }
                    .gesture(doubleTapGesture, isEnabled: !dismissStarted)
            }
            .gesture(dragGesture, isEnabled: !dismissStarted)
            .onAppear {
                containerSize = proxy.size
            }
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
    }
    
    @available(iOS, introduced: 16.0, deprecated: 17.0)
    private var oldMagnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let zoomFactor = 0.5
                let scale = value * zoomFactor
                transform = lastTransform.scaledBy(x: scale, y: scale)
            }
            .onEnded { _ in
                onEndGesture()
            }
    }
    
    @available(iOS 17.0, *)
    private var magnificationGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .onChanged { value in
                let newTransform = CGAffineTransform.anchoredScale(
                    scale: value.magnification,
                    anchor: value.startAnchor.scaledBy(contentSize)
                )
                
                withAnimation(.interactiveSpring) {
                    transform = lastTransform.concatenating(newTransform)
                }
            }
            .onEnded { _ in
                onEndGesture()
            }
    }
    
    private var doubleTapGesture: some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { value in
                let newTransform: CGAffineTransform =
                if transform.isIdentity {
                    .anchoredScale(scale: doubleTapZoomScale, anchor: value.location)
                } else {
                    .identity
                }
                
                withAnimation(.linear(duration: 0.15)) {
                    transform = newTransform
                    lastTransform = newTransform
                }
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring) {
                    transform = lastTransform.translatedBy(
                        x: value.translation.width / transform.scaleX,
                        y: value.translation.height / transform.scaleY
                    )
                }
            }
            .onEnded { value in
                if onDragEnded(transform) {
                    handleDragEnded(predictedEndTranslation: value.predictedEndTranslation, velocity: value.velocity, frameSize: containerSize)
                } else {
                    onEndGesture()
                }
            }
    }
    
    func handleDragEnded(predictedEndTranslation: CGSize, velocity: CGSize, frameSize: CGSize) {
        let dismissDistance = Swift.max(frameSize.width, frameSize.height) * 1.5
        
        let animation: Animation
        let endTranslation: CGSize
        
        if #available(iOS 17, *) {
            endTranslation = predictedEndTranslation.normalized * dismissDistance
            let initialVelocity = velocity.magnitude / dismissDistance
            animation = .interpolatingSpring(.smooth, initialVelocity: initialVelocity)
        } else {
            animation = .spring
            endTranslation = predictedEndTranslation.normalized * dismissDistance
        }
        
        dismissStarted = true
        onStartDismiss()
        withAnimation(animation) {
            transform = lastTransform.translatedBy(
                x: endTranslation.width,
                y: endTranslation.height
            )
        } completion: {
            onDismiss()
            dismissStarted = false
            transform = .identity
            lastTransform = .identity
        }
    }
    
    private func onEndGesture() {
        let newTransform = limitTransform(transform)
        
        withAnimation(.snappy(duration: 0.1)) {
            transform = newTransform
            lastTransform = newTransform
        }
    }
    
    private func limitTransform(_ transform: CGAffineTransform) -> CGAffineTransform {
        let scaleX = transform.scaleX
        let scaleY = transform.scaleY
        
        if scaleX < minZoomScale
            || scaleY < minZoomScale
        {
            return .identity
        }
        
        var transform = transform
        
        let scaledWidth = contentSize.width * transform.scaleX
        let scaledHeight = contentSize.height * transform.scaleY
        
        if scaledWidth > containerSize.width {
            let minTx = -((containerSize.width - contentSize.width) / 2) - (scaledWidth - containerSize.width)
            let maxTx = -((containerSize.width - contentSize.width) / 2)
            transform.tx = min(max(transform.tx, minTx), maxTx)
        } else {
            transform.tx = -contentSize.width * (transform.scaleX - 1) / 2
        }
        
        if scaledHeight > containerSize.height {
            let minTy = -((containerSize.height - contentSize.height) / 2) - (scaledHeight - containerSize.height)
            let maxTy = -((containerSize.height - contentSize.height) / 2)
            transform.ty = min(max(transform.ty, minTy), maxTy)
        } else {
            transform.ty = -contentSize.height * (transform.scaleY - 1) / 2
        }
        
        return transform
    }
    
    private func opacityForBackground(maxYDistance: CGFloat) -> Double {
        if transform.scaleX != minZoomScale || transform.scaleY != minZoomScale {
            return 1
        }
        
        let yDistance = min(abs(transform.ty), maxYDistance)
        return Double(1 - (yDistance / maxYDistance))
    }
}

struct TabItemMediaGestureViewModifier: ViewModifier {
    let minZoomScale: CGFloat
    let doubleTapZoomScale: CGFloat
    let outOfBoundsColor: Color
    
    @State private var lastTransform: CGAffineTransform = .identity
    @State private var transform: CGAffineTransform = .identity
    @State private var containerSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero
    @State private var dismissStarted: Bool = false
    
    let onDragEnded: (CGAffineTransform) -> Bool
    let onStartDismiss: () -> Void
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            ZStack {
                outOfBoundsColor
                    .opacity(opacityForBackground(maxYDistance: 300))
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea()
                
                content
                    .background {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    contentSize = proxy.size
                                }
                                .onChange(of: proxy.size) { _, newValue in
                                    contentSize = newValue
                                }
                        }
                    }
                    // This is a placeholder gesture that prevents the stupid as hell TabView from getting the gesture
                    .gesture(DragGesture(), isEnabled: hasZoomed)
                    .simultaneousGesture(simultaneousDragGesture, isEnabled: !dismissStarted)
                    .modify { view in
                        if #available(iOS 17.0, *) {
                            view.gesture(magnificationGesture, isEnabled: !dismissStarted)
                        } else {
                            view.gesture(oldMagnificationGesture, isEnabled: !dismissStarted)
                        }
                    }
                    .gesture(doubleTapGesture, isEnabled: !dismissStarted)
            }
            .animatableTransformEffect(transform)
            // This is a placeholder gesture that prevents the stupid as hell TabView from getting the gesture
            .gesture(DragGesture(), isEnabled: hasZoomed)
            .simultaneousGesture(simultaneousDragGesture, isEnabled: !dismissStarted)
            .onAppear {
                containerSize = proxy.size
            }
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
    }
    
    private var hasZoomed: Bool {
        return transform.scaleX != 1 || transform.scaleY != 1
    }
    
    @available(iOS, introduced: 16.0, deprecated: 17.0)
    private var oldMagnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let zoomFactor = 0.5
                let scale = value * zoomFactor
                transform = lastTransform.scaledBy(x: scale, y: scale)
            }
            .onEnded { _ in
                onEndGesture()
            }
    }
    
    @available(iOS 17.0, *)
    private var magnificationGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .onChanged { value in
                let newTransform = CGAffineTransform.anchoredScale(
                    scale: value.magnification,
                    anchor: value.startAnchor.scaledBy(contentSize)
                )
                
                withAnimation(.interactiveSpring) {
                    transform = lastTransform.concatenating(newTransform)
                }
            }
            .onEnded { _ in
                onEndGesture()
            }
    }
    
    private var doubleTapGesture: some Gesture {
        SpatialTapGesture(count: 2)
            .onEnded { value in
                let newTransform: CGAffineTransform =
                if transform.isIdentity {
                    .anchoredScale(scale: doubleTapZoomScale, anchor: value.location)
                } else {
                    .identity
                }
                
                withAnimation(.linear(duration: 0.15)) {
                    transform = newTransform
                    lastTransform = newTransform
                }
            }
    }
    
    private var simultaneousDragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                withAnimation(.interactiveSpring) {
                    if abs(value.translation.width) < abs(value.translation.height) || hasZoomed {
                        transform = lastTransform.translatedBy(
                            x: hasZoomed ? value.translation.width / transform.scaleX : 0,
                            y: value.translation.height / transform.scaleY
                        )
                    }
                }
            }
            .onEnded { value in
                if onDragEnded(transform) {
                    handleDragEnded(predictedEndTranslation: value.predictedEndTranslation, velocity: value.velocity, frameSize: containerSize)
                } else {
                    onEndGesture()
                }
            }
    }
    
    func handleDragEnded(predictedEndTranslation: CGSize, velocity: CGSize, frameSize: CGSize) {
        let dismissDistance = Swift.max(frameSize.width, frameSize.height) * 1.5
        
        let animation: Animation
        let endTranslation: CGSize
        
        if #available(iOS 17, *) {
            endTranslation = predictedEndTranslation.normalized * dismissDistance
            let initialVelocity = velocity.magnitude / dismissDistance
            animation = .interpolatingSpring(.smooth, initialVelocity: initialVelocity)
        } else {
            animation = .spring
            endTranslation = predictedEndTranslation.normalized * dismissDistance
        }
        
        dismissStarted = true
        onStartDismiss()
        withAnimation(animation) {
            transform = lastTransform.translatedBy(
                x: endTranslation.width,
                y: endTranslation.height
            )
        } completion: {
            onDismiss()
            dismissStarted = false
            transform = .identity
            lastTransform = .identity
        }
    }
    
    private func onEndGesture() {
        let newTransform = limitTransform(transform)
        
        withAnimation(.snappy(duration: 0.1)) {
            transform = newTransform
            lastTransform = newTransform
        }
    }
    
    private func limitTransform(_ transform: CGAffineTransform) -> CGAffineTransform {
        let scaleX = transform.scaleX
        let scaleY = transform.scaleY
        
        if scaleX < minZoomScale
            || scaleY < minZoomScale
        {
            return .identity
        }
        
        var transform = transform
        
        let scaledWidth = contentSize.width * transform.scaleX
        let scaledHeight = contentSize.height * transform.scaleY
        
        if scaledWidth > containerSize.width {
            let minTx = -((containerSize.width - contentSize.width) / 2) - (scaledWidth - containerSize.width)
            let maxTx = -((containerSize.width - contentSize.width) / 2)
            transform.tx = min(max(transform.tx, minTx), maxTx)
        } else {
            transform.tx = -contentSize.width * (transform.scaleX - 1) / 2
        }
        
        if scaledHeight > containerSize.height {
            let minTy = -((containerSize.height - contentSize.height) / 2) - (scaledHeight - containerSize.height)
            let maxTy = -((containerSize.height - contentSize.height) / 2)
            transform.ty = min(max(transform.ty, minTy), maxTy)
        } else {
            transform.ty = -contentSize.height * (transform.scaleY - 1) / 2
        }
        
        return transform
    }
    
    private func opacityForBackground(maxYDistance: CGFloat) -> Double {
        if transform.scaleX != minZoomScale || transform.scaleY != minZoomScale {
            return 1
        }
        
        let yDistance = min(abs(transform.ty), maxYDistance)
        return Double(1 - (yDistance / maxYDistance))
    }
}

extension CGSize {
    var magnitude: CGFloat {
        sqrt(pow(width, 2) + pow(height, 2))
    }
    
    var normalized: CGSize {
        let mag = magnitude
        guard mag > 0 else { return .zero }
        return CGSize(width: width / mag, height: height / mag)
    }
    
    static func * (size: CGSize, scalar: CGFloat) -> CGSize {
        return CGSize(width: size.width * scalar, height: size.height * scalar)
    }
}
