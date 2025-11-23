//
//  CreateCustomFeedViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import Foundation
import IdentifiedCollections

@MainActor
class CreateOrEditCustomFeedViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var isPrivate: Bool = true
    @Published var subredditsAndUsersInCustomFeed: IdentifiedArrayOf<Thing> = []
    @Published var createOrUpdateCustomFeedTask: Task<Void, Never>?
    @Published var createdOrUpdatedMyCustomFeed: MyCustomFeed?
    @Published var error: Error? = nil
    
    @Published var myCustomFeedToEdit: MyCustomFeed?
    @Published var myCustomFeedToEditLoadState: LoadState = .idle
    
    private let createCustomFeedRepository: CreateOrEditCustomFeedRepositoryProtocol
    
    enum CreateCustomFeedViewModelError: LocalizedError {
        case emptyNameError
        case myCustomFeedToEditIsNilError
        
        var errorDescription: String? {
            switch self {
            case .emptyNameError:
                return "Name cannot be empty."
            case .myCustomFeedToEditIsNilError:
                return "Cannot get the current custom feed to edit."
            }
        }
    }
    
    init(myCustomFeedToEdit: MyCustomFeed?, createCustomFeedRepository: CreateOrEditCustomFeedRepositoryProtocol) {
        self.myCustomFeedToEdit = myCustomFeedToEdit
        self.createCustomFeedRepository = createCustomFeedRepository
    }
    
    func addSubredditsAndUsersInCustomFeed(_ newValues: [Thing]) {
        for newValue in newValues {
            if subredditsAndUsersInCustomFeed.index(id: newValue.id) == nil {
                subredditsAndUsersInCustomFeed.append(newValue)
            }
        }
    }
    
    func removeSubredditAndUserInCustomFeed(_ value: Thing) {
        subredditsAndUsersInCustomFeed.remove(value)
    }
    
    func createOrUpdateCustomFeed() {
        if myCustomFeedToEdit == nil {
            createCustomFeed()
        } else {
            updateCustomFeed()
        }
    }
    
    private func createCustomFeed() {
        guard createOrUpdateCustomFeedTask == nil else {
            return
        }
        
        guard !name.isEmpty else {
            self.error = CreateCustomFeedViewModelError.emptyNameError
            return
        }
        
        createOrUpdateCustomFeedTask = Task {
            do {
                let multipathName: String
                if let spaceIndex = name.firstIndex(of: " ") {
                    multipathName = String(name[..<spaceIndex])
                } else {
                    multipathName = name
                }
                
                self.createdOrUpdatedMyCustomFeed = try await createCustomFeedRepository.createOrUpdateCustomFeed(
                    path: "/user/\(AccountViewModel.shared.account.username)/m/\(multipathName)",
                    name: name,
                    description: description,
                    isPrivate: isPrivate,
                    subredditsAndUsersInCustomFeed: subredditsAndUsersInCustomFeed,
                    isUpdate: false
                )
            } catch {
                self.error = error
                print(error)
            }
            
            createOrUpdateCustomFeedTask = nil
        }
    }
    
    func fetchCustomFeedDetailsToEdit() async {
        guard let myCustomFeedToEdit = myCustomFeedToEdit else {
            return
        }
        
        guard myCustomFeedToEditLoadState.canLoad else {
            return
        }
        
        guard !AccountViewModel.shared.account.isAnonymous() else {
            await fetchCustomFeedDetailsToEditAnonymous()
            return
        }

        myCustomFeedToEditLoadState = .loading
        
        do {
            let customFeed = try await createCustomFeedRepository.fetchCustomFeedDetails(path: myCustomFeedToEdit.path)
            
            name = customFeed.name
            description = customFeed.descriptionMd
            isPrivate = customFeed.visibility == "private"
            for thingInCustomFeed in customFeed.subredditsInCustomFeed {
                subredditsAndUsersInCustomFeed.append(.subredditInCustomFeed(thingInCustomFeed))
            }
            
            myCustomFeedToEditLoadState = .loaded
        } catch {
            myCustomFeedToEditLoadState = .failed(error)
        }
    }
    
    func fetchCustomFeedDetailsToEditAnonymous() async {
        guard let myCustomFeedToEdit = myCustomFeedToEdit else {
            return
        }
        
        myCustomFeedToEditLoadState = .loading
        
        do {
            let anonymousCustomFeedSubreddits = try await createCustomFeedRepository.fetchAnonymousCustomFeedSubreddits(path: myCustomFeedToEdit.path)
            
            name = myCustomFeedToEdit.name
            description = myCustomFeedToEdit.description ?? ""
            isPrivate = myCustomFeedToEdit.visibility == "private"
            for anonymousCustomFeedSubreddit in anonymousCustomFeedSubreddits {
                subredditsAndUsersInCustomFeed.append(.subredditInAnonymousCustomFeed(anonymousCustomFeedSubreddit))
            }
            
            myCustomFeedToEditLoadState = .loaded
        } catch {
            myCustomFeedToEditLoadState = .failed(error)
        }
    }
    
    private func updateCustomFeed() {
        guard createOrUpdateCustomFeedTask == nil else {
            return
        }
        
        guard let myCustomFeedToEdit else {
            self.error = CreateCustomFeedViewModelError.myCustomFeedToEditIsNilError
            return
        }
        
        guard !name.isEmpty else {
            self.error = CreateCustomFeedViewModelError.emptyNameError
            return
        }
        
        createOrUpdateCustomFeedTask = Task {
            do {
                self.createdOrUpdatedMyCustomFeed = try await createCustomFeedRepository.createOrUpdateCustomFeed(
                    path: myCustomFeedToEdit.path,
                    name: name,
                    description: description,
                    isPrivate: isPrivate,
                    subredditsAndUsersInCustomFeed: subredditsAndUsersInCustomFeed,
                    isUpdate: true
                )
            } catch {
                self.error = error
                print(error)
            }
            
            createOrUpdateCustomFeedTask = nil
        }
    }
}
