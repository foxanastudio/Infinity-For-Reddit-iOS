//
//  IconTextButton.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-11.
//

import SwiftUI

struct IconTextButton: View {
    var startIconUrl: String? = nil
    var startIconType: IconType = .systemIcon
    var endIconUrl: String? = nil
    var endIconType: IconType = .systemIcon
    var text: String
    var action: () -> Void
    
    var body: some View {
        TouchRipple(action: action) {
            HStack {
                if let startIconUrl = startIconUrl {
                    switch startIconType {
                    case .webImage:
                        CustomWebImage(
                            startIconUrl,
                            width: 24,
                            height: 24,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                SwiftUI.Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .primaryIcon()
                            }
                        )
                    case .systemIcon:
                        SwiftUI.Image(systemName: startIconUrl)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .primaryIcon()
                    case .icon:
                        SwiftUI.Image(startIconUrl)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .primaryIcon()
                    }
                    
                    Spacer()
                        .frame(width: 32)
                }
                
                Text(text)
                    .primaryText()
                
                Spacer()
                
                if let endIconUrl = endIconUrl {
                    switch endIconType {
                    case .webImage:
                        CustomWebImage(
                            endIconUrl,
                            width: 24,
                            height: 24,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                SwiftUI.Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .primaryIcon()
                            }
                        )
                    case .systemIcon:
                        SwiftUI.Image(systemName: endIconUrl)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .primaryIcon()
                    case .icon:
                        SwiftUI.Image(endIconUrl)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .primaryIcon()
                    }
                }
            }
            .contentShape(Rectangle())
            .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    enum IconType {
        case webImage
        case systemIcon
        case icon
    }
}
