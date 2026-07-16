//
//  ReminderListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

import Foundation

@MainActor
class ReminderListingViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var error: Error?
    
    private let reminderListingRepository: ReminderListingRepositoryProtocol
    
    init(reminderListingRepository: ReminderListingRepositoryProtocol) {
        self.reminderListingRepository = reminderListingRepository
    }
    
    func fetchReminders() async {
        self.error = nil
        
        Task {
            do {
                self.reminders = try await self.reminderListingRepository.getReminders()
            } catch {
                self.error = error
            }
        }
    }
}
