//
//  PostDetailsInterfaceViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import SwiftUI
import Swinject
import GRDB
import Combine

class PostDetailsInterfaceViewModel: ObservableObject {
    // MARK: - Properties
    @Published var separatePostAndCommentsInLandscapeMode: Bool
    @Published var hidePostType: Bool
    @Published var hidePostFlair: Bool
    @Published var hideUpvoteRatio: Bool
    @Published var hideSubredditAndUserPrefix: Bool
    @Published var hideNumberOfVotes: Bool
    @Published var hideNumberOfComments: Bool
    @Published var embeddedMediaType: Int
    
    let SEPARATE_POST_AND_COMMENTS_IN_LANDSCAPE_MODE = UserDefaultsUtils.SEPARATE_POST_AND_COMMENTS_IN_LANDSCAPE_MODE
    let HIDE_POST_TYPE = UserDefaultsUtils.HIDE_POST_TYPE
    let HIDE_POST_FLAIR = UserDefaultsUtils.HIDE_POST_FLAIR
    let HIDE_UPVOTE_RATIO = UserDefaultsUtils.HIDE_UPVOTE_RATIO
    let HIDE_SUBREDDIT_AND_USER_PREFIX = UserDefaultsUtils.HIDE_SUBREDDIT_AND_USER_PREFIX
    let HIDE_NUMBER_OF_VOTES = UserDefaultsUtils.HIDE_THE_NUMBER_OF_VOTES
    let HIDE_NUMBER_OF_COMMENTS = UserDefaultsUtils.HIDE_THE_NUMBER_OF_COMMENTS
    let EMBEDDED_MEDIA_TYPE = UserDefaultsUtils.EMBEDDED_MEDIA_TYPE
    
    let embeddedMediaTypes: [String] = ["All", "Image and GIF", "Image and emote", "GIF and emote", "Image", "GIF", "Emote", "None"]
    
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: SEPARATE_POST_AND_COMMENTS_IN_LANDSCAPE_MODE) == nil {
            userDefaults.set(true, forKey: SEPARATE_POST_AND_COMMENTS_IN_LANDSCAPE_MODE)
        }
        if userDefaults.object(forKey: HIDE_POST_TYPE) == nil {
            userDefaults.set(false, forKey: HIDE_POST_TYPE)
        }
        if userDefaults.object(forKey: HIDE_POST_FLAIR) == nil {
            userDefaults.set(false, forKey: HIDE_POST_FLAIR)
        }
        if userDefaults.object(forKey: HIDE_UPVOTE_RATIO) == nil {
            userDefaults.set(false, forKey: HIDE_UPVOTE_RATIO)
        }
        if userDefaults.object(forKey: HIDE_SUBREDDIT_AND_USER_PREFIX) == nil {
            userDefaults.set(false, forKey: HIDE_SUBREDDIT_AND_USER_PREFIX)
        }
        if userDefaults.object(forKey: HIDE_NUMBER_OF_VOTES) == nil {
            userDefaults.set(false, forKey: HIDE_NUMBER_OF_VOTES)
        }
        if userDefaults.object(forKey: HIDE_NUMBER_OF_COMMENTS) == nil {
            userDefaults.set(false, forKey: HIDE_NUMBER_OF_COMMENTS)
        }
        if userDefaults.object(forKey: EMBEDDED_MEDIA_TYPE) == nil {
            userDefaults.set(0, forKey: EMBEDDED_MEDIA_TYPE)
        }
        
        separatePostAndCommentsInLandscapeMode = userDefaults.bool(forKey: SEPARATE_POST_AND_COMMENTS_IN_LANDSCAPE_MODE)
        hidePostType = userDefaults.bool(forKey: HIDE_POST_TYPE)
        hidePostFlair = userDefaults.bool(forKey: HIDE_POST_FLAIR)
        hideUpvoteRatio = userDefaults.bool(forKey: HIDE_UPVOTE_RATIO)
        hideSubredditAndUserPrefix = userDefaults.bool(forKey: HIDE_SUBREDDIT_AND_USER_PREFIX)
        hideNumberOfVotes = userDefaults.bool(forKey: HIDE_NUMBER_OF_VOTES)
        hideNumberOfComments = userDefaults.bool(forKey: HIDE_NUMBER_OF_COMMENTS)
        embeddedMediaType = userDefaults.integer(forKey: EMBEDDED_MEDIA_TYPE)
        
        $separatePostAndCommentsInLandscapeMode
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.SEPARATE_POST_AND_COMMENTS_IN_LANDSCAPE_MODE ?? "")
            }
            .store(in: &cancellables)
        
        $hidePostType
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.HIDE_POST_TYPE ?? "")
            }
            .store(in: &cancellables)
        
        $hidePostFlair
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.HIDE_POST_FLAIR ?? "")
            }
            .store(in: &cancellables)
        
        $hideUpvoteRatio
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.HIDE_UPVOTE_RATIO ?? "")
            }
            .store(in: &cancellables)
        
        $hideSubredditAndUserPrefix
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.HIDE_SUBREDDIT_AND_USER_PREFIX ?? "")
            }
            .store(in: &cancellables)
        
        $hideNumberOfVotes
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.HIDE_NUMBER_OF_VOTES ?? "")
            }
            .store(in: &cancellables)
        
        $hideNumberOfComments
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.HIDE_NUMBER_OF_COMMENTS ?? "")
            }
            .store(in: &cancellables)
        
        $embeddedMediaType
            .sink { [weak self] newValue in
                self?.savePostDetailsInterfaceSettings(setting: newValue, forKey: self?.EMBEDDED_MEDIA_TYPE ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func savePostDetailsInterfaceSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
}
