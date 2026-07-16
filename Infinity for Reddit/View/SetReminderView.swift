//
//  SetReminderView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-14.
//

import SwiftUI
import Flow

struct SetReminderView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var setReminderViewModel: SetReminderViewModel
    
    @State private var reminderTime = Date(timeInterval: TimeInterval(24 * 60 * 60), since: Date())
    
    init(post: Post, comment: Comment?) {
        _setReminderViewModel = StateObject(wrappedValue: SetReminderViewModel(post: post, comment: comment))
    }
    
    private var predefinedTimes: [(String, Int)] = [
        ("In 6 hours", 6 * 60 * 60),
        ("In 1 day", 24 * 60 * 60),
        ("In 2 days", 48 * 60 * 60),
        ("In 3 days", 72 * 60 * 60),
        ("In 1 week", 7 * 24 * 60 * 60),
        ("In 2 weeks", 14 * 24 * 60 * 60)
    ]
    
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 16) {
                    RowText(setReminderViewModel.contentText)
                        .primaryText()
                        .padding(.horizontal, 16)
                    
                    CustomDivider()
                    
                    RowText("Choose a predefined reminder timer:")
                        .primaryText()
                        .padding(.horizontal, 16)
                    
                    HFlow(alignment: .center) {
                        ForEach(predefinedTimes, id: \.1) { text, time in
                            Button(action: {
                                reminderTime = Date(timeInterval: TimeInterval(time), since: Date())
                                print("Timer set for \(time)")
                            }) {
                                Text(text)
                            }
                            .filledButton(elevate: false)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    CustomDivider()
                    
                    RowText("Or, set a custom reminder time:")
                        .primaryText()
                        .padding(.horizontal, 16)
                    
                    DatePicker(
                        "Date and Time",
                        selection: $reminderTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Set Reminder")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    setReminderViewModel.setReminder(reminderTime: reminderTime)
                } label: {
                    if #available(iOS 26.0, *) {
                        SwiftUI.Image(systemName: "checkmark")
                    } else {
                        SwiftUI.Image(systemName: "checkmark.circle")
                    }
                }
            }
        }
        .showErrorUsingSnackbar(setReminderViewModel.$error)
        .onChange(of: setReminderViewModel.reminderSet) { _, newValue in
            snackbarManager.showSnackbar(.info("Reminder set"))
            dismiss()
        }
    }
}
