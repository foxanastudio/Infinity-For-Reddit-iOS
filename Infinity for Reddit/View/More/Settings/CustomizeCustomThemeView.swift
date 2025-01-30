//
//  CustomizeCustomThemeView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-29.
//

import SwiftUI

struct CustomizeCustomThemeView: View {
    @StateObject var customizeCustomThemeViewModel: CustomizeCustomThemeViewModel
    
    init(customTheme: CustomTheme) {
        _customizeCustomThemeViewModel = StateObject(wrappedValue: CustomizeCustomThemeViewModel(customTheme: customTheme))
    }
    
    var body: some View {
        Text("Customize")
    }
}
