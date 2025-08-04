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
    case postFilter
    case createOrEditPostFilter(postFilter: PostFilter? = nil)
    case postFilterUsageListing(postFilterId: Int)
    case commentFilter
    case sortType
    case downloadLocation
    case miscellaneous
    case advanced
    case manageSubscription
    case about
    case privacyPolicy
    case redditUserAgreement
}
