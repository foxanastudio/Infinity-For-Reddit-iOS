//
//  CustomDivider.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-23.
//

import SwiftUI

struct CustomDivider: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    var body: some View {
        Rectangle()
            .fill(Color(hex: customThemeViewModel.currentCustomTheme.dividerColor))
    }
}
