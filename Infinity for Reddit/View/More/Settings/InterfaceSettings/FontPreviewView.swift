//
//  FontPreviewView.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-14.
//

import SwiftUI

struct FontPreviewView: View {
    @AppStorage(InterfaceFontUserDefaultsUtils.fontSizeKey, store: .interfaceFont) private var fontSize: Int = 2
    
    var body: some View {
        List {
            ForEach(0...16, id: \.self) { index in
                if let fontFamily = FontFamily(rawValue: index) {
                    HStack(spacing: 0) {
                        Spacer()
                            .frame(width: 24)

                        Spacer()
                            .frame(width: 24)

                        VStack(spacing: 4) {
                            RowText(fontFamily.displayName)
                                .font(fontFamily.font(size: InterfaceFontSize(rawValue:fontSize)?.size ?? 17))
                                .primaryText()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .listPlainItemNoInsets()
                }
            }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Font Preview")
    }
}
