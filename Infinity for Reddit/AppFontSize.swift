//
//  FontSize.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-26.
//

import SwiftUI

enum AppFontSize: CGFloat {
    case f11 = 11
    case f12 = 12
    case f13 = 13
    case f15 = 15
    case f17 = 17
    case f20 = 20
    case f22 = 22
    case f24 = 24
    case f56 = 56
}

extension AppFontSize {
    func scaledInterfaceFontSize(_ fontScale: FontScale?, uiFontMetrics: UIFontMetrics) -> CGFloat {
        guard let fontScale else {
            return uiFontMetrics.scaledValue(for: self.rawValue)
        }
        
        return uiFontMetrics.scaledValue(for: {
            switch (self, fontScale) {
            case (.f11, .extraSmall): return 8
            case (.f11, .small): return 10
            case (.f11, .normal): return 11
            case (.f11, .large): return 13
            case (.f11, .extraLarge): return 14
            
            case (.f12, .extraSmall): return 9
            case (.f12, .small): return 11
            case (.f12, .normal): return 12
            case (.f12, .large): return 14
            case (.f12, .extraLarge): return 15
                
            case (.f13, .extraSmall): return 10
            case (.f13, .small): return 12
            case (.f13, .normal): return 13
            case (.f13, .large): return 15
            case (.f13, .extraLarge): return 16
                
            case (.f15, .extraSmall): return 12
            case (.f15, .small): return 14
            case (.f15, .normal): return 15
            case (.f15, .large): return 17
            case (.f15, .extraLarge): return 18
                
            case (.f17, .extraSmall): return 14
            case (.f17, .small): return 16
            case (.f17, .normal): return 17
            case (.f17, .large): return 19
            case (.f17, .extraLarge): return 20
                
            case (.f20, .extraSmall): return 17
            case (.f20, .small): return 19
            case (.f20, .normal): return 20
            case (.f20, .large): return 22
            case (.f20, .extraLarge): return 23
                
            case (.f22, .extraSmall): return 19
            case (.f22, .small): return 21
            case (.f22, .normal): return 22
            case (.f22, .large): return 24
            case (.f22, .extraLarge): return 25
                
            case (.f24, .extraSmall): return 21
            case (.f24, .small): return 23
            case (.f24, .normal): return 24
            case (.f24, .large): return 25
            case (.f24, .extraLarge): return 27
                
            case (.f56, .extraSmall): return 52
            case (.f56, .small): return 55
            case (.f56, .normal): return 56
            case (.f56, .large): return 57
            case (.f56, .extraLarge): return 59
            }
        }())
    }
    
    func scaledPostTitleFontSize(_ fontScale: FontScale?, uiFontMetrics: UIFontMetrics) -> CGFloat {
        guard let fontScale else {
            return uiFontMetrics.scaledValue(for: self.rawValue)
        }
        
        return uiFontMetrics.scaledValue(for: {
            switch (self, fontScale) {
            case (.f11, .extraSmall): return 8
            case (.f11, .small): return 10
            case (.f11, .normal): return 11
            case (.f11, .large): return 13
            case (.f11, .extraLarge): return 14
            
            case (.f12, .extraSmall): return 9
            case (.f12, .small): return 11
            case (.f12, .normal): return 12
            case (.f12, .large): return 14
            case (.f12, .extraLarge): return 15
                
            case (.f13, .extraSmall): return 10
            case (.f13, .small): return 12
            case (.f13, .normal): return 13
            case (.f13, .large): return 15
            case (.f13, .extraLarge): return 16
                
            case (.f15, .extraSmall): return 12
            case (.f15, .small): return 14
            case (.f15, .normal): return 15
            case (.f15, .large): return 17
            case (.f15, .extraLarge): return 18
                
            case (.f17, .extraSmall): return 14
            case (.f17, .small): return 16
            case (.f17, .normal): return 17
            case (.f17, .large): return 19
            case (.f17, .extraLarge): return 20
                
            case (.f20, .extraSmall): return 17
            case (.f20, .small): return 19
            case (.f20, .normal): return 20
            case (.f20, .large): return 22
            case (.f20, .extraLarge): return 23
                
            case (.f22, .extraSmall): return 19
            case (.f22, .small): return 21
            case (.f22, .normal): return 22
            case (.f22, .large): return 24
            case (.f22, .extraLarge): return 25
                
            case (.f24, .extraSmall): return 21
            case (.f24, .small): return 23
            case (.f24, .normal): return 24
            case (.f24, .large): return 25
            case (.f24, .extraLarge): return 27
                
            case (.f56, .extraSmall): return 52
            case (.f56, .small): return 55
            case (.f56, .normal): return 56
            case (.f56, .large): return 57
            case (.f56, .extraLarge): return 59
            }
        }())
    }
    
    func scaledContentFontSize(_ fontScale: ContentFontScale?, uiFontMetrics: UIFontMetrics? = nil) -> CGFloat {
        guard let fontScale else {
            if let uiFontMetrics = uiFontMetrics {
                return uiFontMetrics.scaledValue(for: self.rawValue)
            }
            
            return self.rawValue
        }
        
        if let uiFontMetrics = uiFontMetrics {
            return uiFontMetrics.scaledValue(for: getRawContentFontSize(fontScale))
        }
        
        return getRawContentFontSize(fontScale)
    }
    
    private func getRawContentFontSize(_ fontScale: ContentFontScale) -> CGFloat {
        switch (self, fontScale) {
        case (.f11, .extraSmall): return 8
        case (.f11, .small): return 10
        case (.f11, .normal): return 11
        case (.f11, .large): return 13
        case (.f11, .extraLarge): return 14
        case (.f11, .enormouslyLarge): return 16
        
        case (.f12, .extraSmall): return 9
        case (.f12, .small): return 11
        case (.f12, .normal): return 12
        case (.f12, .large): return 14
        case (.f12, .extraLarge): return 15
        case (.f12, .enormouslyLarge): return 17
            
        case (.f13, .extraSmall): return 10
        case (.f13, .small): return 12
        case (.f13, .normal): return 13
        case (.f13, .large): return 15
        case (.f13, .extraLarge): return 16
        case (.f13, .enormouslyLarge): return 18
            
        case (.f15, .extraSmall): return 12
        case (.f15, .small): return 14
        case (.f15, .normal): return 15
        case (.f15, .large): return 17
        case (.f15, .extraLarge): return 18
        case (.f15, .enormouslyLarge): return 20
            
        case (.f17, .extraSmall): return 14
        case (.f17, .small): return 16
        case (.f17, .normal): return 17
        case (.f17, .large): return 19
        case (.f17, .extraLarge): return 20
        case (.f17, .enormouslyLarge): return 22
            
        case (.f20, .extraSmall): return 17
        case (.f20, .small): return 19
        case (.f20, .normal): return 20
        case (.f20, .large): return 22
        case (.f20, .extraLarge): return 23
        case (.f20, .enormouslyLarge): return 25
            
        case (.f22, .extraSmall): return 19
        case (.f22, .small): return 21
        case (.f22, .normal): return 22
        case (.f22, .large): return 24
        case (.f22, .extraLarge): return 25
        case (.f22, .enormouslyLarge): return 27
            
        case (.f24, .extraSmall): return 21
        case (.f24, .small): return 23
        case (.f24, .normal): return 24
        case (.f24, .large): return 25
        case (.f24, .extraLarge): return 27
        case (.f24, .enormouslyLarge): return 29
            
        case (.f56, .extraSmall): return 52
        case (.f56, .small): return 55
        case (.f56, .normal): return 56
        case (.f56, .large): return 57
        case (.f56, .extraLarge): return 59
        case (.f56, .enormouslyLarge): return 61
        }
    }
}
