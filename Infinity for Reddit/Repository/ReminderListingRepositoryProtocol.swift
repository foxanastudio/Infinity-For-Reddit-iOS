//
//  ReminderListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-07-15.
//

protocol ReminderListingRepositoryProtocol {
    func getReminders() async throws -> [Reminder]
}
