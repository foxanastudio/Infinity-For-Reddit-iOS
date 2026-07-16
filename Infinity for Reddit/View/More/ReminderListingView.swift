//
//  ReminderListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

import SwiftUI

struct ReminderListingView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject private var reminderListingViewModel: ReminderListingViewModel
    
    init() {
        _reminderListingViewModel = StateObject(wrappedValue: ReminderListingViewModel(reminderListingRepository: ReminderListingRepository()))
    }
    var body: some View {
        RootView {
            List {
                ForEach(reminderListingViewModel.reminders, id: \.self) { reminder in
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            RowText("\(reminder.commentId.isEmpty ? "Post" : "Comment")")
                                .primaryText()
                            
                            Text(getElapsedTime(reminder: reminder))
                                .primaryText()
                        }
                        
                        RowText(reminder.content)
                            .secondaryText()
                    }
                    .listPlainItemNoInsets()
                    .padding(16)
                    .background(Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor))
                    .contentShape(RoundedRectangle(cornerRadius: 16))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        navigationManager.append(
                            AppNavigation.postDetails(
                                postDetailsInput: .postAndCommentId(
                                    postId: reminder.postId, commentId: reminder.commentId.isEmpty ? nil : reminder.commentId
                                ),
                                videoPlaybackTime: 0
                            )
                        )
                    }
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Reminders")
        .task {
            await reminderListingViewModel.fetchReminders()
        }
        .showErrorUsingSnackbar(reminderListingViewModel.$error)
    }
    
    func getElapsedTime(reminder: Reminder) -> String {
        let now = Int64(Date().timeIntervalSince1970)
        let diff = Int64(reminder.reminderTime) - now
        
        if diff < 0 {
            return "Expired"
        } else if diff < 2 * TimeConstants.minute {
            return "In 1 min"
        } else if diff < 50 * TimeConstants.minute {
            return "In \(diff / TimeConstants.minute) mins"
        } else if diff < 120 * TimeConstants.minute {
            return "In 1 hour"
        } else if diff < 24 * TimeConstants.hour {
            return "In \(diff / TimeConstants.hour) hours"
        } else if diff < 48 * TimeConstants.hour {
            return "In 1 day"
        } else if diff < TimeConstants.month {
            return "In \(diff / TimeConstants.day) days"
        } else if diff < 2 * TimeConstants.month {
            return "In 1 month"
        } else if diff < TimeConstants.year {
            return "In \(diff / TimeConstants.month) months"
        } else if diff < 2 * TimeConstants.year {
            return "In 1 year"
        } else {
            return "In \(diff / TimeConstants.year) years"
        }
    }
}
