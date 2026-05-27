//
//  AppStoreEventView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-27.
//

import SwiftUI

struct AppStoreEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    var body: some View {
        RootView {
            if UIDevice.isIPad {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        GeometryReader { geometry in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 16) {
                                    HStack(spacing: 16) {
                                        VStack(spacing: 8) {
                                            SwiftUI.Image(systemName: "safari.fill")
                                                .font(.system(size: 44))
                                                .primaryIcon()
                                            
                                            Text("Safari")
                                                .primaryText()
                                        }
                                        
                                        SwiftUI.Image(systemName: "arrow.right")
                                            .primaryIcon()
                                        
                                        VStack(spacing: 8) {
                                            SwiftUI.Image("onboarding_app_icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 48)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                            
                                            Text("Infinity")
                                                .primaryText()
                                        }
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    VStack(spacing: 8) {
                                        RowText("Open Reddit Links in Infinity")
                                            .fontWeight(.bold)
                                            .primaryText(.f56)
                                        
                                        RowText("Jump directly from Reddit webpages into Infinity while browsing in Safari.")
                                            .secondaryText(.f20)
                                    }
                                }
                                .frame(minHeight: geometry.size.height)
                                .padding(.vertical, 16)
                                .padding(.leading, 32)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        GeometryReader { geometry in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 24) {
                                    VStack(spacing: 12) {
                                        HStack(spacing: 12) {
                                            SwiftUI.Image(systemName: "arrow.up.right.square")
                                                .foregroundStyle(.orange)
                                            
                                            RowText("Automatically opens Reddit links in Infinity")
                                                .primaryText()
                                        }
                                        
                                        HStack(spacing: 12) {
                                            SwiftUI.Image(systemName: "sparkles")
                                                .foregroundStyle(.purple)
                                            
                                            RowText("Removes web pop-ups and distractions")
                                                .primaryText()
                                        }
                                        
                                        HStack(spacing: 12) {
                                            SwiftUI.Image(systemName: "safari")
                                                .foregroundStyle(.blue)
                                            
                                            RowText("Works directly inside Safari")
                                                .primaryText()
                                        }
                                    }
                                    .padding(20)
                                    .filledCardBackground()
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .clipped()
                                    .padding(.bottom, 6)
                                    
                                    VStack(alignment: .leading, spacing: 18) {
                                        HStack(spacing: 12) {
                                            SwiftUI.Image(systemName: "list.number")
                                                .primaryIcon()
                                            
                                            RowText("How to Enable the Extension")
                                                .primaryText()
                                        }
                                        
                                        VStack(spacing: 8) {
                                            HStack(spacing: 12) {
                                                SwiftUI.Image(systemName: "1.circle.fill")
                                                    .primaryIcon()
                                                
                                                RowText("Open Safari")
                                                    .secondaryText()
                                            }
                                            
                                            HStack(spacing: 12) {
                                                SwiftUI.Image(systemName: "2.circle.fill")
                                                    .primaryIcon()
                                                
                                                RowText("Tap the extension or the settings icon in the address bar")
                                                    .secondaryText()
                                            }
                                            
                                            HStack(spacing: 12) {
                                                SwiftUI.Image(systemName: "3.circle.fill")
                                                    .primaryIcon()
                                                
                                                RowText("Select \"Manage Extensions\" (optional)")
                                                    .secondaryText()
                                            }
                                            
                                            HStack(spacing: 12) {
                                                SwiftUI.Image(systemName: "4.circle.fill")
                                                    .primaryIcon()
                                                
                                                RowText("Turn on \"Open in Infinity\"")
                                                    .secondaryText()
                                            }
                                        }
                                        
                                        CustomDivider()
                                        
                                        HStack {
                                            HStack(spacing: 12) {
                                                SwiftUI.Image("onboarding_app_icon")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                
                                                RowText("Open in Infinity")
                                                    .primaryText()
                                            }
                                            
                                            Spacer()
                                            
                                            Toggle("", isOn: .constant(false))
                                                .labelsHidden()
                                                .disabled(true)
                                        }
                                        
                                        RowText("Turn this on inside Safari")
                                            .secondaryText()
                                    }
                                    .padding(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color(hex: customThemeViewModel.currentCustomTheme.primaryTextColor), lineWidth: 1)
                                    )
                                    
                                    HStack(spacing: 12) {
                                        SwiftUI.Image(systemName: "lightbulb.max.fill")
                                            .foregroundStyle(.yellow)
                                            .font(.system(size: 20))
                                        
                                        Text("Need a break? Tap the extension or the settings icon in Safari, select Open in Infinity, and use the toggle inside the popup to quickly pause or resume redirects.")
                                            .secondaryText()
                                    }
                                }
                                .padding(.vertical, 16)
                                .padding(.trailing, 32)
                                .frame(minHeight: geometry.size.height)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Button {
                            if let url = URL(string: "x-safari-https://www.reddit.com/r/Infinity_For_Reddit") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                            dismiss()
                        } label: {
                            Text("Open Safari to Enable")
                                .customFont()
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                        .filledButton()
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Maybe Later")
                                .colorAccentText()
                        }
                    }
                    .padding(24)
                }
                .background {
                    if let confettiPath = Bundle.main.path(forResource: "Confetti", ofType:"png"), let confetti = UIImage(named: confettiPath) {
                        SwiftUI.Image(uiImage: confetti)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(0.15)
                    }
                }
            } else {
                RootView {
                    NewFeatureView()
                        .background {
                            if let confettiPath = Bundle.main.path(forResource: "Confetti", ofType:"png"), let confetti = UIImage(named: confettiPath) {
                                SwiftUI.Image(uiImage: confetti)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .opacity(0.15)
                            }
                        }
                }
            }
        }
        .themedNavigationBar()
    }
}

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
