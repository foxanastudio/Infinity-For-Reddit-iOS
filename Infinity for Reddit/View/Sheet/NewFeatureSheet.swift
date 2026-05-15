//
//  NewFeatureSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-05-15.
//

import SwiftUI

struct NewFeatureSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    SwiftUI.Image(systemName: "safari.fill")
                                        .font(.system(size: 32))
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
                                        .frame(width: 36)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    Text("Infinity")
                                        .primaryText()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 8) {
                                Text("Open Reddit Links in Infinity")
                                    .fontWeight(.bold)
                                    .primaryText(.f24)
                                
                                Text("Jump directly from Reddit webpages into Infinity while browsing in Safari.")
                                    .secondaryText()
                            }
                        }
                        
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
                                    
                                    RowText("Tap the extension or \"aA\" icon in the address bar")
                                        .secondaryText()
                                }
                                
                                HStack(spacing: 12) {
                                    SwiftUI.Image(systemName: "3.circle.fill")
                                        .primaryIcon()
                                    
                                    RowText("Select \"Manage Extensions\"")
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
                            
                            Text("Tip: Need a break? Tap the extension or \"aA\" icon in Safari, select Open in Infinity, and use the toggle inside the popup to quickly pause or resume redirects.")
                                .secondaryText()
                        }
                    }
                    .padding(24)
                }
                .scrollIndicators(.hidden)
                
                VStack(spacing: 12) {
                    Button {
                        //UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
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
        }
    }
}
