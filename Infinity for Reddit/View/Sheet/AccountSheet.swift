//
//  ProfileSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import SwiftUI
import SDWebImageSwiftUI
import GRDB

struct AccountSheet: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var accountViewModel: AccountViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject var accountListingViewModel: AccountListingViewModel
    
    @State private var showLoginHelpMessage: Bool = false
    
    private let profileImageSize: CGFloat = 86
    private let onLogin: () -> Void
    
    init(onLogin: @escaping () -> Void) {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        self.onLogin = onLogin
        _accountListingViewModel = StateObject(wrappedValue: AccountListingViewModel(dbPool: resolvedDBPool))
    }
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
                        CustomWebImage(
                            accountViewModel.account.bannerImageUrl,
                            height: 120,
                            handleImageTapGesture: false,
                            fallbackView: {
                                Spacer()
                                    .frame(height: 120)
                            }
                        )
                        
                        CustomWebImage(
                            accountViewModel.account.profileImageUrl,
                            width: profileImageSize,
                            height: profileImageSize,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                if accountViewModel.account.isAnonymous() {
                                    SwiftUI.Image(systemName: "questionmark.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: profileImageSize, height: profileImageSize)
                                        .primaryIcon()
                                } else {
                                    InitialLetterAvatarImageFallbackView(name: accountViewModel.account.username, size: profileImageSize)
                                }
                            }
                        )
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    VStack {
                        Text(accountViewModel.account.isAnonymous() == true ? "Anonymous" : accountViewModel.account.username)
                            .primaryText(.f24)
                            .fontWeight(.bold)
                        
                        if accountViewModel.account.isAnonymous() != true {
                            Text("Karma: \(accountViewModel.account.karma)")
                                .primaryText()
                        }
                        
                        Spacer()
                            .frame(height: 8)
                    }
                    
                    if accountViewModel.account.isAnonymous() != true {
                        SimpleTouchItemRow(text: "Profile", icon: "person.crop.circle") {
                            dismiss()
                            navigationManager.append(AppNavigation.userDetails(username: accountViewModel.account.username))
                        }
                    }
                    
                    ForEach(accountListingViewModel.otherAccounts, id: \.username) { account in
                        SimpleWebImageTouchItemRow(text: account.username, iconUrl: account.profileImageUrl ?? "") {
                            AccountViewModel.shared.switchAccount(newAccount: account)
                            dismiss()
                        }
                    }
                    
                    SimpleTouchItemRow(text: "Add account", icon: "person.crop.circle.badge.plus") {
                        onLogin()
                    }
                    
                    if accountViewModel.account.isAnonymous() == false {
                        SimpleTouchItemRow(text: "Use Anonymous Mode", icon: "person.fill.questionmark") {
                            do {
                                try accountViewModel.switchToAnonymous()
                            } catch {
                                printInDebugOnly("Failed to log out: \(error)")
                            }
                            dismiss()
                        }
                        
                        SimpleTouchItemRow(text: "Log out", icon: "rectangle.portrait.and.arrow.right") {
                            do {
                                try accountViewModel.logout()
                            } catch {
                                printInDebugOnly("Failed to log out: \(error)")
                            }
                            dismiss()
                        }
                    }
                    
                    SimpleTouchItemRow(text: "Having trouble signing in?", icon: "info.circle") {
                        withAnimation {
                            showLoginHelpMessage = true
                        }
                    }
                }
            }
        }
        .overlay {
            if let loginError = accountViewModel.error as? LoginError {
                RootView {
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Text("Contact Us")
                                .neutralTextButton()
                                .onTapGesture {
                                    if let url = URL(string: "mailto:support@foxanastudio.com") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            
                            Spacer()
                            
                            Text("Done")
                                .positiveTextButton()
                                .onTapGesture {
                                    withAnimation {
                                        accountViewModel.error = nil
                                    }
                                }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        
                        ScrollView {
                            RowText(loginError.localizedDescription)
                                .fontWeight(.bold)
                                .padding(.bottom, 16)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            } else if showLoginHelpMessage {
                RootView {
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Text("Contact Us")
                                .neutralTextButton()
                                .onTapGesture {
                                    if let url = URL(string: "mailto:support@foxanastudio.com") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            
                            Spacer()
                            
                            Text("Done")
                                .positiveTextButton()
                                .onTapGesture {
                                    withAnimation {
                                        showLoginHelpMessage = false
                                    }
                                }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        
                        ScrollView {
                            RowText(
                                    """
                                    If the keyboard isn’t appearing, try zooming out of the webpage. Click the reader icon in the toolbar (next to the refresh button), then tap the zoom control at the bottom and reduce the zoom level.\n
                                    This should allow the webpage to display the cookie agreement prompt. Please select “Agree” when it appears.\n
                                    If needed, you can adjust the zoom level back to your preferred size afterward.\n
                                    If you don't see any cookie agreement dialog, you can tap the same reader icon and then tap the 3-dot icon next to the zoom control, and select Request Desktop Site. Or you can rotate your phone into landscape mode. Keyboard will now open when you click on the username or password field.\n
                                    If you need further assistance, feel free to contact us by email: support@foxanastudio.com
                                    """
                            )
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }
}
