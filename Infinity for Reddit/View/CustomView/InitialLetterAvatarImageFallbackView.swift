//
//  InitialLetterAvatarImageFallbackView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-19.
//

import SwiftUI

struct InitialLetterAvatarImageFallbackView: View {
    @AppStorage(InterfaceFontUserDefaultsUtils.fontFamilyKey, store: .interfaceFont) private var fontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.fontScaleKey, store: .interfaceFont) private var fontScale: Int = 2
    
    let name: String?
    var size: CGFloat
    
    private var initial: String {
        if let name = name {
            return name.isEmpty ? "?" : String(name.first ?? "?").uppercased()
        }
        
        return "?"
    }
    
    var body: some View {
        Text(initial)
            .font((FontFamily(rawValue: fontFamily) ?? .system).font(size: size * 0.6))
            .fontWeight(.bold)
            .frame(width: size, height: size)
            .foregroundColor(.white)
            .background(Color.gray)
            .clipShape(Circle())
            .offset(y: 1)
    }
}
