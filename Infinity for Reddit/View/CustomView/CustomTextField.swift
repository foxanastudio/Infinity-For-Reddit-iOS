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
    private let characterLimit: Int?
    private let customTextFieldScheme: CustomTextFieldScheme
    private let showBorder: Bool
    private let showBackground: Bool
    private let fieldType: FieldType
    
    init(_ placeholder: String = "",
         text: Binding<String>,
         singleLine: Bool = false,
         keyboardType: UIKeyboardType = .default,
         autocapitalization: TextInputAutocapitalization? = nil,
         characterLimit: Int? = nil,
         customTextFieldScheme: CustomTextFieldScheme = .normal,
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
        self.characterLimit = characterLimit
        self.customTextFieldScheme = customTextFieldScheme
        self.showBorder = showBorder
        self.showBackground = showBackground
        self.fieldType = fieldType
        self._focusedField = focusedField
    }
    
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: prompt,
            axis: singleLine ? .horizontal : .vertical
        )
        .keyboardType(keyboardType)
        .textInputAutocapitalization(autocapitalization)
        .autocorrectionDisabled(true)
        .modify {
            if #available(iOS 26, *) {
                $0
            } else {
                $0.foregroundStyle(customTextFieldScheme.getTextColor(currentCustomTheme: customThemeViewModel.currentCustomTheme))
                    .tint(customTextFieldScheme.getTintColor(currentCustomTheme: customThemeViewModel.currentCustomTheme))
            }
        }
        .applyIf(characterLimit != nil) {
            $0.onReceive(text.publisher.collect()) {
                if let characterLimit {
                    self.text = String($0.prefix(characterLimit))
                }
            }
        }
        .applyIf(showBorder) {
            // TODO different border color for different focus state
            $0.padding(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: customThemeViewModel.currentCustomTheme.primaryTextColor), lineWidth: 1)
                )
        }
        .applyIf(showBackground) {
            $0.padding(16)
                .background(Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor))
                .cornerRadius(10)
        }
        .focused($focusedField, equals: fieldType)
    }
    
    var prompt: Text {
        if #available(iOS 26, *) {
            Text(placeholder)
        } else {
            Text(placeholder)
                .foregroundStyle(customTextFieldScheme.getHintColor(currentCustomTheme: customThemeViewModel.currentCustomTheme))
        }
    }
}

enum CustomTextFieldScheme {
    case normal
    case fab
    
    func getHintColor(currentCustomTheme: CustomTheme) -> Color {
        switch self {
        case .normal:
            return Color(hex: currentCustomTheme.secondaryTextColor)
        case .fab:
            return Color(hex: currentCustomTheme.fabIconColor, opacity: 0.8)
        }
    }
    
    func getTextColor(currentCustomTheme: CustomTheme) -> Color {
        switch self {
        case .normal:
            return Color(hex: currentCustomTheme.primaryTextColor)
        case .fab:
            return Color(hex: currentCustomTheme.fabIconColor)
        }
    }
    
    func getTintColor(currentCustomTheme: CustomTheme) -> Color {
        switch self {
        case .normal:
            return Color(hex: currentCustomTheme.colorPrimaryLightTheme)
        case .fab:
            return Color(hex: currentCustomTheme.fabIconColor)
        }
    }
}
