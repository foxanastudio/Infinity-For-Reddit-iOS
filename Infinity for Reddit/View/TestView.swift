//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @State private var value: Double = 12
    @State private var isEditing = false
    
    var body: some View {
        List(1...10, id: \.self) { index in
            Text("\(index)")
        }
        .listStyle(.plain)
    }
}
