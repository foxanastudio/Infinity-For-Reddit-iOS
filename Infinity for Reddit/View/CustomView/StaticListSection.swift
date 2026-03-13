//
//  StaticListSection.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-03-13.
//

import SwiftUI

struct StaticListSection: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        RowText(title)
            .padding(16)
            .limitedWidth()
            .listSectionHeader()
            .listPlainItemNoInsets()
    }
}
