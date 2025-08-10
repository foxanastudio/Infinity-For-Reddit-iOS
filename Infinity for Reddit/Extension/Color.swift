//
//  Color.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-31.
//

import SwiftUI

extension Color {
    init(hex: Int) {
        if hex > 0xFFFFFF {
            // Has alpha channel
            let alpha = Double((hex >> 24) & 0xFF) / 255.0
            let red = Double((hex >> 16) & 0xFF) / 255.0
            let green = Double((hex >> 8) & 0xFF) / 255.0
            let blue = Double(hex & 0xFF) / 255.0
            
            self.init(red: red, green: green, blue: blue, opacity: alpha)
        } else {
            let alpha = 1.0
            let red = Double((hex >> 16) & 0xFF) / 255.0
            let green = Double((hex >> 8) & 0xFF) / 255.0
            let blue = Double(hex & 0xFF) / 255.0
            
            self.init(red: red, green: green, blue: blue, opacity: alpha)
        }
    }
    
    init(hex: Int, opacity: Double) {
        if hex > 0xFFFFFF {
            // Has alpha channel
            let red = Double((hex >> 16) & 0xFF) / 255.0
            let green = Double((hex >> 8) & 0xFF) / 255.0
            let blue = Double(hex & 0xFF) / 255.0
            
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        } else {
            let red = Double((hex >> 16) & 0xFF) / 255.0
            let green = Double((hex >> 8) & 0xFF) / 255.0
            let blue = Double(hex & 0xFF) / 255.0
            
            self.init(red: red, green: green, blue: blue, opacity: opacity)
        }
    }
    
    init(hex: String, default defaultColor: Color = .clear) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self = defaultColor
            return
        }
        
        let length = hexSanitized.count
        let r, g, b, a: Double
        
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8) / 255
            a = Double(rgb & 0x000000FF) / 255
        } else {
            self = defaultColor
            return
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension Color {
    func toHex() -> Int {
        guard let components = UIColor(self).cgColor.components else { return 0x000000 }
        let alpha = Int(components[3] * 255)
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return (alpha << 24) | (r << 16) | (g << 8) | b
    }
}
