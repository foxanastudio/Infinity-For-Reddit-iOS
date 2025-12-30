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
    
    private let profileImageSize: CGFloat = 86
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        _accountListingViewModel = StateObject(wrappedValue: AccountListingViewModel(dbPool: resolvedDBPool))
    }
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 20) {
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
                    
                    VStack(spacing: 0) {
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
                            dismiss()
                            navigationManager.append(AppNavigation.login)
                        }
                        
                        if accountViewModel.account.isAnonymous() == false {
                            SimpleTouchItemRow(text: "Anonymous", icon: "person.fill.questionmark") {
                                do {
                                    try accountViewModel.switchToAnonymous()
                                } catch {
                                    print("Failed to log out: \(error)")
                                }
                                dismiss()
                            }
                            
                            SimpleTouchItemRow(text: "Log out", icon: "rectangle.portrait.and.arrow.right") {
                                do {
                                    try accountViewModel.logout()
                                } catch {
                                    print("Failed to log out: \(error)")
                                }
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}
