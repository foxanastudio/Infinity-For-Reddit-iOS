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
    let outOfBoundsColor: Color?
    
    @State private var lastTransform: CGAffineTransform = .identity
    @State private var transform: CGAffineTransform = .identity
    @State private var contentSize: CGSize = .zero
    let onDragEnded: (CGAffineTransform) -> Bool
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        if let outOfBoundsColor = outOfBoundsColor {
            ZStack {
                outOfBoundsColor
                    .opacity(opacityForBackground(maxYDistance: 300))
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea()
                
                content
                    .background(alignment: .topLeading) {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    contentSize = proxy.size
                                }
                        }
                    }
                    .animatableTransformEffect(transform)
                    .gesture(dragGesture)
                    .modify { view in
                        if #available(iOS 17.0, *) {
                            view.gesture(magnificationGesture)
                        } else {
                            view.gesture(oldMagnificationGesture)
                        }
                    }
                    .gesture(doubleTapGesture)
            }
            .gesture(dragGesture)
        } else {
            content
                .background(alignment: .topLeading) {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                contentSize = proxy.size
                            }
                    }
                }
                .animatableTransformEffect(transform)
                .gesture(dragGesture)
                .modify { view in
                    if #available(iOS 17.0, *) {
                        view.gesture(magnificationGesture)
                    } else {
                        view.gesture(oldMagnificationGesture)
                    }
                }
                .gesture(doubleTapGesture)
        }
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
            .onEnded { _ in
                if onDragEnded(transform) {
                    withAnimation {
                        onDismiss()
                    } completion: {
                        transform = .identity
                        lastTransform = .identity
                    }
                } else {
                    onEndGesture()
                }
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
        
        let maxX = contentSize.width * (scaleX - 1)
        let maxY = contentSize.height * (scaleY - 1)
        
        if transform.tx > 0
            || transform.tx < -maxX
            || transform.ty > 0
            || transform.ty < -maxY
        {
            let tx = min(max(transform.tx, -maxX), 0)
            let ty = min(max(transform.ty, -maxY), 0)
            var transform = transform
            transform.tx = tx
            transform.ty = ty
            return transform
        }
        
        return transform
    }
    
    private func opacityForBackground(maxYDistance: CGFloat) -> Double {
        if transform.scaleX > minZoomScale || transform.scaleY > minZoomScale {
            return 1
        }
        
        let yDistance = min(abs(transform.ty), maxYDistance)
        return Double(1 - (yDistance / maxYDistance))
    }
}
