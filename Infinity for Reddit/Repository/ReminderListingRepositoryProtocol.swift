//
//  ReminderListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

import Combine

protocol ReminderListingRepositoryProtocol {
    func getRemindersPublisher() -> AnyPublisher<[Reminder], Error>
    func deleteReminder(_ reminder: Reminder) async throws
}
