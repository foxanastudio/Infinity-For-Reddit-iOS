//
//  Infinity_for_RedditApp.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-27.
//

import SwiftUI
import Swinject
import GRDB
import GiphyUISDK

@main
struct Infinity: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var accountViewModel: AccountViewModel
    @StateObject var customThemeViewModel: CustomThemeViewModel
    @StateObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @StateObject var networkManager: NetworkManager = NetworkManager()
    
    let container: Container = {
        let container = Container()
        return container
    }()
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        AccountViewModel.initializeShared(using: DependencyManager.shared.container)
        _accountViewModel = StateObject(wrappedValue: AccountViewModel.shared)
        _customThemeViewModel = StateObject(wrappedValue: CustomThemeViewModel())
        _fullScreenMediaViewModel = StateObject(wrappedValue: FullScreenMediaViewModel())
        
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            }
        }
        
        NotificationDelegate.shared.configure()
        PullNotificationBackgroundTaskManager.shared.registerAndScheduleBackgroundTask()

        FontUtils.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            HomeView(fullScreenMediaViewModel: fullScreenMediaViewModel)
                .id(accountViewModel.account.username)
                .environment(\.dependencyManager, DependencyManager.shared.container)
                .environmentObject(accountViewModel)
                .environmentObject(customThemeViewModel)
                .environmentObject(fullScreenMediaViewModel)
                .environmentObject(networkManager)
                .environment(\.defaultMinListRowHeight, 0)
                .onOpenURL { url in
                    guard let appDeepLinkType = AppDeepLink.getAppDeepLinkType(url) else {
                        return
                    }
                    switch appDeepLinkType {
                    case .inbox(let account, let viewMessage, let fullname):
                        var userInfo: [String: Any] = [
                            AppDeepLink.accountNameKey: account,
                            AppDeepLink.viewMessageKey: viewMessage
                        ]
                        if let fullname {
                            userInfo[AppDeepLink.fullnameKey] = fullname
                        }
                        NotificationCenter.default.post(name: .inboxDeepLink, object: nil, userInfo: userInfo)
                    case .context(let account, let context, let fullname):
                        var userInfo: [String: Any] = [
                            AppDeepLink.accountNameKey: account,
                            AppDeepLink.contextKey: context
                        ]
                        if let fullname {
                            userInfo[AppDeepLink.fullnameKey] = fullname
                        }
                        NotificationCenter.default.post(name: .contextDeepLink, object: nil, userInfo: userInfo)
                    }
                }
                .onAppear {
                    Giphy.configure(apiKey: APIUtils.GIPHY_GIF_API_KEY)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background, NotificationUserDefaultsUtils.enableNotification  {
                PullNotificationBackgroundTaskManager.shared.scheduleBackgroundTask()
            }
        }
    }
}
