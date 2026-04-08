//
//  NavigationStackItemViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-29.
//

import SwiftUI

struct NavigationStackItemViewModifier: ViewModifier {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @State private var showProfile: Bool = false
    
    let onLogin: () -> Void
    
    private let userIconSize: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        CustomWebImage(
                            accountViewModel.account.profileImageUrl,
                            width: userIconSize,
                            height: userIconSize,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                if accountViewModel.account.isAnonymous() {
                                    SwiftUI.Image(systemName: anonymousIconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: userIconSize, height: userIconSize)
                                        .navigationBarImage()
                                } else {
                                    InitialLetterAvatarImageFallbackView(name: accountViewModel.account.username, size: userIconSize)
                                }
                            }
                        )
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationBarMenu()
                }
            }
            .themedNavigationBar()
            .wrapContentSheet(isPresented: $showProfile) {
                AccountSheet(onLogin: onLogin)
            }
    }
    
    var anonymousIconName: String {
        if #available(iOS 26, *) {
            return "questionmark"
        } else {
            return "questionmark.circle"
        }
    }
}
