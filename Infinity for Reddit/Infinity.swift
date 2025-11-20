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
    let container: Container = {
        let container = Container()
        return container
    }()
    
    @StateObject var accountViewModel: AccountViewModel
    @StateObject var customThemeViewModel: CustomThemeViewModel
    @StateObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @StateObject var networkManager: NetworkManager = NetworkManager()
    
    @Environment(\.scenePhase) private var scenePhase
    
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
            HomeView()
                .id(accountViewModel.account.username)
                .environment(\.dependencyManager, DependencyManager.shared.container)
                .environmentObject(accountViewModel)
                .environmentObject(customThemeViewModel)
                .environmentObject(fullScreenMediaViewModel)
                .environmentObject(networkManager)
                .environment(\.defaultMinListRowHeight, 0)
                .onOpenURL { url in
                    guard let parsed = AppDeepLink.parse(url) else { return }
                    switch parsed {
                    case .external(let external):
                        LinkHandler.shared.handle(url: external)

                    case .inbox(let account, let viewMessage, let fullname):
                        var info: [String: Any] = [
                            "accountName": account,
                            "viewMessage": viewMessage
                        ]
                        if let fullname { info["messageFullname"] = fullname }
                        NotificationCenter.default.post(name: .inboxDeepLink, object: nil, userInfo: info)
                    case .link(let externalUrl, let account, _):
                        Task {
                            await accountViewModel.switchToAccountIfNeeded(account)
                            LinkHandler.shared.handle(url: externalUrl)
                        }
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
