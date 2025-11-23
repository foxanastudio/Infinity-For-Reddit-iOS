//
//  CustomTextField.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-01.
//

import SwiftUI

struct CustomTextField<FieldType: Hashable>: View {
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    @FocusState.Binding private var focusedField: FieldType?
    
    @Binding private var text: String
    private var placeholder: String
    private let singleLine: Bool
    private let keyboardType: UIKeyboardType
    private let autocapitalization: TextInputAutocapitalization?
    private let showBorder: Bool
    private let showBackground: Bool
    private let fieldType: FieldType
    
    init(_ placeholder: String = "",
         text: Binding<String>,
         singleLine: Bool = false,
         keyboardType: UIKeyboardType = .default,
         autocapitalization: TextInputAutocapitalization? = nil,
         showBorder: Bool = false,
         showBackground: Bool = true,
         fieldType: FieldType,
         focusedField: FocusState<FieldType?>.Binding
    ) {
        self.placeholder = placeholder
        _text = text
        self.singleLine = singleLine
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.showBorder = showBorder
        self.showBackground = showBackground
        self.fieldType = fieldType
        self._focusedField = focusedField
    }
    
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundStyle(Color(hex: customThemeViewModel.currentCustomTheme.secondaryTextColor)),
            axis: singleLine ? .horizontal : .vertical
        )
        .primaryText()
        .keyboardType(keyboardType)
        .textInputAutocapitalization(autocapitalization)
        .tint(Color(hex: customThemeViewModel.currentCustomTheme.colorPrimary))
        .applyIf(showBorder) {
            // TODO different border color for different focus state
            $0.padding(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: customThemeViewModel.currentCustomTheme.primaryTextColor), lineWidth: 1)
                )
        }
        .applyIf(showBackground) {
            $0.padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color(.systemGray5))
                .cornerRadius(10)
        }
        .focused($focusedField, equals: fieldType)
    }
}
