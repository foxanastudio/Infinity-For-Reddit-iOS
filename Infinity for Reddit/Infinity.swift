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
import Kingfisher
import LocalAuthentication

@main
struct Infinity: App {
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var accountViewModel: AccountViewModel
    @StateObject private var customThemeViewModel: CustomThemeViewModel
    @StateObject private var fullScreenMediaViewModel: FullScreenMediaViewModel
    @StateObject private var networkManager: NetworkManager = NetworkManager()
    
    @State private var showAppLockScreen: Bool = false
    @State private var authenticationSuccess: Bool = false
    
    @AppStorage(SecurityUserDefaultsUtils.appLockKey, store: .security) private var appLock: Bool = false
    @AppStorage(SecurityUserDefaultsUtils.appLockTimeoutKey, store: .security) private var appLockTimeout: Int = 600000
    
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

        ProxyManager.shared.start()
        KingfisherManager.shared.defaultOptions += [.requestModifier(ProxyRequestModifier())]
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
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
                
                if showAppLockScreen {
                    VStack {
                        Color.blue
                    }
                    .zIndex(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        try? await Task.sleep(for: .seconds(1))
                        authenticate()
                    }
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background  {
                if NotificationUserDefaultsUtils.enableNotification {
                    PullNotificationBackgroundTaskManager.shared.scheduleBackgroundTask()
                }
                if appLock && !showAppLockScreen{
                    SecurityUserDefaultsUtils.saveLastForegroundTime()
                }
            } else if newPhase == .active {
                if appLock && Int(Utils.getCurrentTimeEpoch()) - SecurityUserDefaultsUtils.getLastForegroundTime() >= appLockTimeout {
                    if showAppLockScreen {
                        if authenticationSuccess {
                            withAnimation {
                                showAppLockScreen = false
                            }
                        }
                    } else {
                        withAnimation {
                            showAppLockScreen = true
                        }
                    }
                }
            }
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We use Face ID to confirm it’s you before entering the app."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                authenticationSuccess = success
            }
        }
    }
}
