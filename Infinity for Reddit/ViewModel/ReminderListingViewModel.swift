//
//  ReminderListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

import Foundation
import Combine

@MainActor
class ReminderListingViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var error: Error?
    
    private let reminderListingRepository: ReminderListingRepositoryProtocol
    
    private let remindersPublisher: AnyPublisher<[Reminder], Error>
    
    private var cancellables = Set<AnyCancellable>()
    
    init(reminderListingRepository: ReminderListingRepositoryProtocol) {
        self.reminderListingRepository = reminderListingRepository
        self.remindersPublisher = reminderListingRepository.getRemindersPublisher()
        
        remindersPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] reminders in
                self?.reminders = reminders
            })
            .store(in: &cancellables)
    }
    
    func deleteReminder(_ reminder: Reminder) async {
        do {
            try await self.reminderListingRepository.deleteReminder(reminder)
        } catch {
            self.error = error
        }
    }
}
