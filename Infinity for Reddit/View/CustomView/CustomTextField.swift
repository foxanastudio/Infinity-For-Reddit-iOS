//
//  CustomTextField.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-01.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    
    init(_ placeholder: String = "", text: Binding<String>) {
        self.placeholder = placeholder
        _text = text
    }
    
    var body: some View {
        TextField(placeholder, text: $text)
    }
}
