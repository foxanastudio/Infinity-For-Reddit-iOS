//
//  AnonymousSubscriptionListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-09.
//

protocol AnonymousSubscriptionListingRepositoryProtocol {
    func toggleFavoriteSubreddit(_ subscribedSubreddit: SubscribedSubredditData) -> Bool
    func toggleFavoriteUser(_ subscribedUser: SubscribedUserData) -> Bool
    func toggleFavoriteCustomFeed(_ customFeed: MyCustomFeed) -> Bool
}
