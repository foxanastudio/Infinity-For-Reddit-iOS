//
// PillViewModifier.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-09-04
        
import SwiftUI

struct PillButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    let isSelected: Bool
    let selectedBackGround: Int
    let selectedForeGround: Int
    let defaultBackGround: Int
    let defaultForeGround: Int
    let defaultBorder: Int
    
    let cornerRadius: CGFloat
    let fontSize: CGFloat
    let borderWidth: CGFloat
    
    func body(content: Content) -> some View {
        let theme = themeViewModel.currentCustomTheme
        
        let bg = isSelected ? Color(hex: selectedBackGround) : Color(hex: defaultBackGround)
        let fg = isSelected ? Color(hex: selectedForeGround) : Color(hex: defaultForeGround)
        let border = isSelected ? Color(hex: selectedBackGround) : Color(hex: defaultBorder)
        
        content
            .font(.system(size: fontSize))
            .foregroundColor(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius).fill(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border, lineWidth: borderWidth)
            )
    }
}



