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
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        _accountListingViewModel = StateObject(wrappedValue: AccountListingViewModel(dbPool: resolvedDBPool))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    CustomWebImage(
                        accountViewModel.account.bannerImageUrl,
                        height: 150,
                        handleImageTapGesture: false,
                        fallbackView: {
                            Spacer()
                                .frame(height: 150)
                        }
                    )
                    
                    CustomWebImage(
                        accountViewModel.account.profileImageUrl,
                        width: 96,
                        height: 96,
                        circleClipped: true,
                        handleImageTapGesture: false,
                        fallbackView: {
                            SwiftUI.Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 96, height: 96)
                        }
                    )
                }
                
                VStack(spacing: 20) {
                    VStack {
                        Text(accountViewModel.account.isAnonymous() == true ? "Anonymous" : accountViewModel.account.username)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if accountViewModel.account.isAnonymous() != true {
                            Text("Karma: \(accountViewModel.account.karma)")
                                .primaryText()
                        }
                    }
                    
                    if accountViewModel.account.isAnonymous() != true {
                        IconTextButton(startIconUrl: "person.crop.circle", text: "Profile") {
                            dismiss()
                            navigationManager.path.append(AppNavigation.userDetails(username: accountViewModel.account.username))
                        }
                    }
                    
                    ForEach(accountListingViewModel.otherAccounts, id: \.username) { account in
                        IconTextButton(startIconUrl: account.profileImageUrl ?? "", startIconType: .webImage, text: account.username) {
                            do {
                                AccountViewModel.shared.switchAccount(newAccount: account)
                                try AccountViewModel.shared.updateTokens(accessToken: account.accessToken ?? "", refreshToken: account.refreshToken ?? "")
                            }
                            catch{
                                print("Error: switching account failed")
                            }
                            
                            dismiss()
                        }
                    }
                    
                    IconTextButton(startIconUrl: "person.crop.circle.badge.plus", text: "Add account") {
                        dismiss()
                        navigationManager.path.append(AppNavigation.login)
                    }
                    
                    if accountViewModel.account.isAnonymous() == false {
                        IconTextButton(startIconUrl: "person.fill.questionmark", text: "Anonymous") {
                            do {
                                try accountViewModel.switchToAnonymous()
                            } catch {
                                print("Failed to log out: \(error)")
                            }
                            dismiss()
                        }
                        
                        IconTextButton(startIconUrl: "rectangle.portrait.and.arrow.right", text: "Log out") {
                            do {
                                try accountViewModel.logout()
                            } catch {
                                print("Failed to log out: \(error)")
                            }
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
