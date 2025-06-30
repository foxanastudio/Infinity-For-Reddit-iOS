//
//  IconTextButton.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-11.
//

import SwiftUI

struct IconTextButton: View {
    var startIconUrl: String
    var startIsWebImage: Bool = false
    var endIconUrl: String? = nil
    var endIsWebImage: Bool = false
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if startIsWebImage {
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
                } else {
                    SwiftUI.Image(systemName: startIconUrl)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .primaryIcon()
                }
                
                Spacer()
                    .frame(width: 32)
                
                Text(text)
                    .primaryText()
                
                Spacer()
                
                if let endIconUrl = endIconUrl {
                    if endIsWebImage {
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
                    } else {
                        SwiftUI.Image(systemName: endIconUrl)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .primaryIcon()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
