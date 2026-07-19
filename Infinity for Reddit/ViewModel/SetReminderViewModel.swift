//
//  SetReminderViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-14.
//

import Foundation

@MainActor
class SetReminderViewModel: ObservableObject {
    @Published var reminderTime: Int
    @Published var error: Error?
    @Published var isSettingReminder: Bool = false
    @Published var reminderSet: Bool = false
    
    let post: Post?
    let comment: Comment?
    var contentText: String {
        if let commentBody = comment?.body {
            return commentBody.substring(to: 200)
        }
        
        return post?.title ?? "Can't get content text."
    }
    
    enum SetReminderError: LocalizedError {
        case invalidTime
        case saveToDatabaseFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidTime:
                return "Make sure the reminder time is in the future."
            case .saveToDatabaseFailed:
                return "Cannot save this reminder to database. Please try again."
            }
        }
    }
    
    init(post: Post?, comment: Comment?) {
        self.reminderTime = Utils.getCurrentTimeEpochInSecond()
        self.post = post
        self.comment = comment
    }
    
    func setReminder(reminderTime: Date) {
        guard !self.isSettingReminder else {
            return
        }
        
        guard reminderTime.timeIntervalSince1970 > TimeInterval(Utils.getCurrentTimeEpochInSecond()) else {
            self.error = SetReminderError.invalidTime
            return
        }
        
        self.isSettingReminder = true
        
        let reminder = Reminder(
            accountName: AccountViewModel.shared.account.username,
            postId: post?.id ?? comment?.linkId ?? "",
            commentId: comment?.id ?? "",
            content: contentText,
            createdAt: Utils.getCurrentTimeEpochInSecond(),
            reminderTime: Int(reminderTime.timeIntervalSince1970)
        )
        
        Task {
            do {
                try await ReminderManager.shared.setReminder(reminder: reminder)
                self.reminderSet = true
            } catch {
                self.error = SetReminderError.saveToDatabaseFailed
            }
            self.isSettingReminder = false
        }
    }
}
