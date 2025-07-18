//
//  View.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-05.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
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
