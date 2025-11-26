//
//  Font.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-15.
//

import SwiftUI

extension View {
    func customFont(fontSize: AppFontSize = .f17) -> some View {
        modifier(CustomFontModifier(fontSize: fontSize))
    }

    func customPostTitleFont(fontSize: AppFontSize = .f17) -> some View {
        modifier(CustomPostTitleFontModifier(fontSize: fontSize))
    }

    func customContentFont(fontSize: AppFontSize = .f15) -> some View {
        modifier(CustomContentFontModifier(fontSize: fontSize))
    }
}
