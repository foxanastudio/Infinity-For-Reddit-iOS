//
//  CommentIndentationView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-03.
//

import SwiftUI

struct CommentIndentationView: View {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    let depth: Int
    
    var depthColors: [Color] {
        [
            Color(hex: themeViewModel.currentCustomTheme.commentVerticalBarColor1),
            Color(hex: themeViewModel.currentCustomTheme.commentVerticalBarColor2),
            Color(hex: themeViewModel.currentCustomTheme.commentVerticalBarColor3),
            Color(hex: themeViewModel.currentCustomTheme.commentVerticalBarColor4),
            Color(hex: themeViewModel.currentCustomTheme.commentVerticalBarColor5),
            Color(hex: themeViewModel.currentCustomTheme.commentVerticalBarColor6),
            Color(hex: themeViewModel.currentCustomTheme.commentVerticalBarColor7)
        ]
    }
    
    var body: some View {
        if depth > 0 {
            HStack(spacing: 8) {
                ForEach(0..<depth, id:\.self) { depth in
                    Rectangle()
                        .fill(depthColors[depth % depthColors.count])
                        .frame(width: 2)
                }
            }
            .padding(.leading, 10)
        }
    }
}
