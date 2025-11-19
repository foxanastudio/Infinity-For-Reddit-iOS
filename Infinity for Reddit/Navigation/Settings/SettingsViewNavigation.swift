//
//  SettingsViewNavigation.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-04.
//

enum SettingsViewNavigation: Hashable {
    case notification
    case interface
    case theme
    case video
    case gesturesAndButtons
    case security
    case dataSavingMode
    case proxy
    case postHistory
    case contentSensitivityFilter
    case postFilter(postToBeAdded: Post? = nil)
    case createOrEditPostFilter(postFilter: PostFilter? = nil, postToBeAdded: Post? = nil, selectedFieldsToAddToPostFilter: [SelectedFieldToAddToPostFilter]? = nil)
    case postFilterUsageListing(postFilterId: Int)
    case commentFilter
    case createOrEditCommentFilter(commentFilter: CommentFilter? = nil)
    case commentFilterUsageListing(commentFilterId: Int)
    case sortType
    case miscellaneous
    case advanced
    case manageSubscription
    case about
}
