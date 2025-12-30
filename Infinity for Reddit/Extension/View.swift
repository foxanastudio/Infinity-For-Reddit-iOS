//
//  View.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-05.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyIf<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func getHeightOfView( completion: @escaping (_ height: Double) -> Void) -> some View {
        self.background {
            GeometryReader {
                Color.clear.preference(
                    key: ViewHeightKeyTestScreen.self,
                    value: $0.frame(in: .local).size.height
                )
            }
        }.onPreferenceChange(ViewHeightKeyTestScreen.self) {
            completion($0)
        }
    }
}

struct ViewHeightKeyTestScreen: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ fn: (Self) -> some View) -> some View {
        fn(self)
    }
    
    @ViewBuilder
    func animatableTransformEffect(_ transform: CGAffineTransform) -> some View {
        scaleEffect(
            x: transform.scaleX,
            y: transform.scaleY,
            anchor: .zero
        )
        .offset(x: transform.tx, y: transform.ty)
    }
}

extension UnitPoint {
    func scaledBy(_ size: CGSize) -> CGPoint {
        .init(
            x: x * size.width,
            y: y * size.height
        )
    }
}

extension CGAffineTransform {
    static func anchoredScale(scale: CGFloat, anchor: CGPoint) -> CGAffineTransform {
        CGAffineTransform(translationX: anchor.x, y: anchor.y)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -anchor.x, y: -anchor.y)
    }
    
    var scaleX: CGFloat {
        sqrt(a * a + c * c)
    }
    
    var scaleY: CGFloat {
        sqrt(b * b + d * d)
    }
}
