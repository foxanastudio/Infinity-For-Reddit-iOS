//
//  Font.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-15.
//

import SwiftUI

extension View {
    func customFont() -> some View {
        modifier(CustomFontModifier())
    }

    func customPostTitleFont() -> some View {
        modifier(CustomPostTitleFontModifier())
    }

    func customContentFont() -> some View {
        modifier(CustomContentFontModifier())
    }
}
