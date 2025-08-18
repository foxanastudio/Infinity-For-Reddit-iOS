//
//  Infinity_for_RedditApp.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-27.
//

import SwiftUI
import Swinject
import GRDB

@main
struct Infinity: App {
    let container: Container = {
        let container = Container()
        return container
    }()
    
    @StateObject var accountViewModel: AccountViewModel
    @StateObject var customThemeViewModel: CustomThemeViewModel
    @StateObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @StateObject var notificationRouter = NotificationRouter.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        
        AccountViewModel.initializeShared(using: DependencyManager.shared.container)
        _accountViewModel = StateObject(wrappedValue: AccountViewModel.shared)
        _customThemeViewModel = StateObject(wrappedValue: CustomThemeViewModel())
        _fullScreenMediaViewModel = StateObject(wrappedValue: FullScreenMediaViewModel())
        
//        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            if settings.authorizationStatus == .notDetermined {
                _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            }
        }
        
        NotificationDelegate.shared.configure()
        BackgroundTasksManager.shared.registerBackgroundTask()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.dependencyManager, DependencyManager.shared.container)
                .environmentObject(accountViewModel)
                .environmentObject(customThemeViewModel)
                .environmentObject(fullScreenMediaViewModel)
                .environmentObject(notificationRouter)
                .environment(\.defaultMinListRowHeight, 0)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background  {
                BackgroundTasksManager.shared.scheduleAppRefresh()
            }
        }
    }
}
