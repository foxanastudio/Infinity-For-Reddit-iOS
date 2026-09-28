//
//  CustomThemeListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-20.
//

import Foundation
import Combine
import GRDB
import UniformTypeIdentifiers

@MainActor
class CustomThemeListingViewModel: ObservableObject {
    @Published var customThemes: [CustomTheme] = []
    @Published var error: Error?
    @Published var customThemeToShare: CustomTheme?
    
    private let customThemeDao: CustomThemeDao
    private let customThemeListingRepository: CustomThemeListingRepositoryProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    var document: String? {
        guard let customThemeToShare else {
            return nil
        }
        
        return try? customThemeToShare.exportJSON()
    }
    
    init(customThemeListingRepository: CustomThemeListingRepositoryProtocol) {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool in CustomThemeListingViewModel")
        }
        
        self.customThemeDao = CustomThemeDao(dbPool: resolvedDatabasePool)
        self.customThemeListingRepository = customThemeListingRepository
        
        subscribeToThemes()
    }
    
    func subscribeToThemes() {
        customThemeDao.getAllCustomThemesPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    printInDebugOnly("Error fetching themes: \(error)")
                }
            }, receiveValue: { [weak self] themes in
                self?.customThemes = themes
            })
            .store(in: &cancellables)
    }
    
    func deleteTheme(_ customTheme: CustomTheme) {
        Task {
            do {
                try await customThemeListingRepository.deleteTheme(customTheme)
            } catch {
                printInDebugOnly(error)
                self.error = error
            }
        }
    }
}
