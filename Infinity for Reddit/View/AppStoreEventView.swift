//
//  AppStoreEventView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-27.
//

import SwiftUI

struct AppStoreEventView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    var body: some View {
        RootView {
            if UIDevice.isIPad {
                HStack(spacing: 16) {
                    GeometryReader { geometry in
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 8) {
                                    SwiftUI.Image(systemName: "star.fill")
                                        .buttonIcon()
                                        .font(.system(size: 24))
                                    
                                    Text("Major Update")
                                        .buttonText(.f24)
                                }
                                .padding(8)
                                .background(Color(hex: customThemeViewModel.currentCustomTheme.colorPrimaryLightTheme))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .clipped()
                                
                                RowText("Never lose your place in comments")
                                    .primaryText(.f56)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                    .frame(height: 32)
                                
                                RowText("Jump back to the exact comment you were reading")
                                    .secondaryText(.f20)
                                
                                Spacer()
                                    .frame(height: 8)
                                
                                RowText("No more starting from the top every time")
                                    .secondaryText(.f20)
                                
                                Spacer()
                                    .frame(height: 32)
                                
                                RowText("Here’s how it works:")
                                    .secondaryText()
                            }
                            .frame(minHeight: geometry.size.height)
                            .padding(.vertical, 32)
                            .padding(.leading, 32)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    GeometryReader { geometry in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if let step1Path = Bundle.main.path(forResource: "Step1", ofType:"png"),
                                   let step2Path = Bundle.main.path(forResource: "Step2", ofType:"png"),
                                   let step3Path = Bundle.main.path(forResource: "Step3", ofType:"png"),
                                   let step4Path = Bundle.main.path(forResource: "Step4", ofType:"png") {
                                    if let step1 = UIImage(named: step1Path),
                                       let step2 = UIImage(named: step2Path),
                                       let step3 = UIImage(named: step3Path),
                                       let step4 = UIImage(named: step4Path) {
                                        
                                        SwiftUI.Image(uiImage: step1)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .padding(.trailing, 32)
                                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                                        
                                        SwiftUI.Image(uiImage: step2)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .padding(.trailing, 32)
                                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                                        
                                        SwiftUI.Image(uiImage: step3)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .padding(.trailing, 32)
                                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                                        
                                        SwiftUI.Image(uiImage: step4)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .padding(.trailing, 32)
                                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
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
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 8) {
                                    SwiftUI.Image(systemName: "star.fill")
                                        .buttonIcon()
                                    
                                    Text("Major Update")
                                        .buttonText()
                                }
                                .padding(8)
                                .background(Color(hex: customThemeViewModel.currentCustomTheme.colorPrimaryLightTheme))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .clipped()
                                
                                RowText("Never lose your place in comments")
                                    .primaryText(.f56)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                    .frame(height: 32)
                                
                                RowText("Jump back to the exact comment you were reading")
                                    .secondaryText(.f20)
                                
                                Spacer()
                                    .frame(height: 8)
                                
                                RowText("No more starting from the top every time")
                                    .secondaryText(.f20)
                                
                                Spacer()
                                    .frame(height: 32)
                                
                                RowText("Here’s how it works:")
                                    .secondaryText()
                                
                                Spacer()
                                    .frame(height: 16)
                            }
                            .padding(.top, geometry.safeAreaInsets.top)
//                            .background {
//                                if let confettiPath = Bundle.main.path(forResource: "Confetti", ofType:"png"), let confetti = UIImage(named: confettiPath) {
//                                    SwiftUI.Image(uiImage: confetti)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .opacity(0.1)
//                                }
//                            }
                            
                            if let step1Path = Bundle.main.path(forResource: "Step1", ofType:"png"),
                               let step2Path = Bundle.main.path(forResource: "Step2", ofType:"png"),
                               let step3Path = Bundle.main.path(forResource: "Step3", ofType:"png"),
                               let step4Path = Bundle.main.path(forResource: "Step4", ofType:"png") {
                                if let step1 = UIImage(named: step1Path),
                                   let step2 = UIImage(named: step2Path),
                                   let step3 = UIImage(named: step3Path),
                                   let step4 = UIImage(named: step4Path) {
                                    
                                    SwiftUI.Image(uiImage: step1)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    Spacer()
                                        .frame(height: 16)
                                    
                                    SwiftUI.Image(uiImage: step2)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    Spacer()
                                        .frame(height: 16)
                                    
                                    SwiftUI.Image(uiImage: step3)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    Spacer()
                                        .frame(height: 16)
                                    
                                    SwiftUI.Image(uiImage: step4)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                        .padding(16)
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
                    .ignoresSafeArea(edges: .top)
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
