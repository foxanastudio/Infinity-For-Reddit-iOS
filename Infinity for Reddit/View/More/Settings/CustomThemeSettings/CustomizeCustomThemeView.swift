//
//  CustomizeCustomThemeView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-29.
//

import SwiftUI

struct CustomizeCustomThemeView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var customizeCustomThemeViewModel: CustomizeCustomThemeViewModel
    @State var title: String?
    @State var showColorPicker: Bool = false
    @FocusState private var focusedField: FieldType?
    
    init(customTheme: CustomTheme) {
        _customizeCustomThemeViewModel = StateObject(wrappedValue: CustomizeCustomThemeViewModel(customTheme: customTheme))
    }
    
    var body: some View {
        VStack {
            List {
                VStack(alignment: .leading, spacing: 0) {
                    CustomTextField("Name", text: $customizeCustomThemeViewModel.customTheme.name, singleLine: true, fieldType: FieldType.name, focusedField: $focusedField)
                        .padding(16)
                    
                    Divider()
                }
                .listPlainItemNoInsets()
                
                ForEach(customizeCustomThemeViewModel.customThemeFields, id: \.self) { fieldName in
                    if customizeCustomThemeViewModel.customThemeFieldsBoolType.contains(fieldName) {
                        if let binding = getBooleanBinding(for: fieldName) {
                            BooleanEntry(
                                fieldName: fieldName,
                                title: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.title ?? "",
                                // Notice we use the same string as the title
                                description: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.title ?? "",
                                isEnabled: binding
                            )
                            .listPlainItemNoInsets()
                        }
                    } else {
                        if let colorBinding = getIntBinding(for: fieldName) {
                            ColorEntry(
                                fieldName: fieldName,
                                title: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.title ?? "",
                                description: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.description ?? "",
                                color: getWrappedBinding(for: colorBinding)
                            )
                            .listPlainItemNoInsets()
                        }
                    }
                }
            }
            
            KeyboardToolbar {
                focusedField = nil
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    customizeCustomThemeViewModel.saveCustomTheme()
                    dismiss()
                }) {
                    SwiftUI.Image(systemName: "tray.and.arrow.down")
                        .navigationBarImage()
                }
            }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Customize", 1.0)
    }
    
    private struct ColorEntry: View {
        let fieldName: String
        let title: String
        let description: String
        let color: IdentifiableBinding<Int>
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .primaryText()
                        
                        Spacer()
                            .frame(height: 8)
                        
                        Text(description)
                            .font(.system(size: 14))
                            .secondaryText()
                    }
                    .padding(16)
                    
                    Spacer()
                    
                    ColorPicker("Choose color", selection: Binding(
                        get: { Color(hex: color.binding.wrappedValue) },
                        set: { newColor in
                            color.binding.wrappedValue = newColor.toHex()
                        }
                    ))
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 16)
                    .padding(.trailing, 16)
                    .labelsHidden()
                }
                .frame(maxWidth: .infinity)
                
                Divider()
            }
        }
    }
    
    private struct BooleanEntry: View {
        let fieldName: String
        let title: String
        let description: String
        let isEnabled: Binding<Bool>
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .primaryText()
                        
                        Spacer()
                            .frame(height: 8)
                        
                        Text(description)
                            .font(.system(size: 14))
                            .secondaryText()
                    }
                    .padding(16)
                    
                    Spacer()
                    
                    Toggle(isOn: isEnabled) {}
                        .padding(.vertical, 16)
                        .padding(.trailing, 16)
                        .labelsHidden()
                        .themedToggle()
                }
                .frame(maxWidth: .infinity)
                
                Divider()
            }
        }
    }
    
    private func getWrappedBinding<T>(for binding: Binding<T>) -> IdentifiableBinding<T> {
        return IdentifiableBinding(binding: Binding(
            get: { binding.wrappedValue },
            set: { newValue in
                binding.wrappedValue = newValue
                customizeCustomThemeViewModel.objectWillChange.send()
            }
        ))
    }
    
    private func getBooleanBinding(for fieldName: String) -> Binding<Bool>? {
        switch fieldName {
        case "isLightTheme":
            return $customizeCustomThemeViewModel.customTheme.isLightTheme
        case "isDarkTheme":
            return $customizeCustomThemeViewModel.customTheme.isDarkTheme
        case "isAmoledTheme":
            return $customizeCustomThemeViewModel.customTheme.isAmoledTheme
        case "isLightStatusBar":
            return $customizeCustomThemeViewModel.customTheme.isLightStatusBar
        case "isLightNavBar":
            return $customizeCustomThemeViewModel.customTheme.isLightNavBar
        case "isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface":
            return $customizeCustomThemeViewModel.customTheme.isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface
        default:
            return nil
        }
    }
    
    private func getIntBinding(for fieldName: String) -> Binding<Int>? {
        switch fieldName {
        case "colorPrimary":
            return $customizeCustomThemeViewModel.customTheme.colorPrimary
        case "colorPrimaryDark":
            return $customizeCustomThemeViewModel.customTheme.colorPrimaryDark
        case "colorAccent":
            return $customizeCustomThemeViewModel.customTheme.colorAccent
        case "colorPrimaryLightTheme":
            return $customizeCustomThemeViewModel.customTheme.colorPrimaryLightTheme
        case "primaryTextColor":
            return $customizeCustomThemeViewModel.customTheme.primaryTextColor
        case "secondaryTextColor":
            return $customizeCustomThemeViewModel.customTheme.secondaryTextColor
        case "postTitleColor":
            return $customizeCustomThemeViewModel.customTheme.postTitleColor
        case "postContentColor":
            return $customizeCustomThemeViewModel.customTheme.postContentColor
        case "readPostTitleColor":
            return $customizeCustomThemeViewModel.customTheme.readPostTitleColor
        case "readPostContentColor":
            return $customizeCustomThemeViewModel.customTheme.readPostContentColor
        case "commentColor":
            return $customizeCustomThemeViewModel.customTheme.commentColor
        case "buttonTextColor":
            return $customizeCustomThemeViewModel.customTheme.buttonTextColor
        case "chipTextColor":
            return $customizeCustomThemeViewModel.customTheme.chipTextColor
        case "linkColor":
            return $customizeCustomThemeViewModel.customTheme.linkColor
        case "receivedMessageTextColor":
            return $customizeCustomThemeViewModel.customTheme.receivedMessageTextColor
        case "sentMessageTextColor":
            return $customizeCustomThemeViewModel.customTheme.sentMessageTextColor
        case "backgroundColor":
            return $customizeCustomThemeViewModel.customTheme.backgroundColor
        case "cardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.cardViewBackgroundColor
        case "readPostCardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.readPostCardViewBackgroundColor
        case "filledCardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.filledCardViewBackgroundColor
        case "readPostFilledCardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.readPostFilledCardViewBackgroundColor
        case "commentBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.commentBackgroundColor
        case "fullyCollapsedCommentBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.fullyCollapsedCommentBackgroundColor
        case "awardedCommentBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.awardedCommentBackgroundColor
        case "receivedMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.receivedMessageBackgroundColor
        case "sentMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.sentMessageBackgroundColor
        case "bottomAppBarBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.bottomAppBarBackgroundColor
        case "primaryIconColor":
            return $customizeCustomThemeViewModel.customTheme.primaryIconColor
        case "bottomAppBarIconColor":
            return $customizeCustomThemeViewModel.customTheme.bottomAppBarIconColor
        case "postIconAndInfoColor":
            return $customizeCustomThemeViewModel.customTheme.postIconAndInfoColor
        case "commentIconAndInfoColor":
            return $customizeCustomThemeViewModel.customTheme.commentIconAndInfoColor
        case "fabIconColor":
            return $customizeCustomThemeViewModel.customTheme.fabIconColor
        case "sendMessageIconColor":
            return $customizeCustomThemeViewModel.customTheme.sendMessageIconColor
        case "toolbarPrimaryTextAndIconColor":
            return $customizeCustomThemeViewModel.customTheme.toolbarPrimaryTextAndIconColor
        case "toolbarSecondaryTextColor":
            return $customizeCustomThemeViewModel.customTheme.toolbarSecondaryTextColor
        case "circularProgressBarBackground":
            return $customizeCustomThemeViewModel.customTheme.circularProgressBarBackground
        case "mediaIndicatorIconColor":
            return $customizeCustomThemeViewModel.customTheme.mediaIndicatorIconColor
        case "mediaIndicatorBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.mediaIndicatorBackgroundColor
        case "tabLayoutWithExpandedCollapsingToolbarTabBackground":
            return $customizeCustomThemeViewModel.customTheme.tabLayoutWithExpandedCollapsingToolbarTabBackground
        case "tabLayoutWithExpandedCollapsingToolbarTextColor":
            return $customizeCustomThemeViewModel.customTheme.tabLayoutWithExpandedCollapsingToolbarTextColor
        case "tabLayoutWithExpandedCollapsingToolbarTabIndicator":
            return $customizeCustomThemeViewModel.customTheme.tabLayoutWithExpandedCollapsingToolbarTabIndicator
        case "tabLayoutWithCollapsedCollapsingToolbarTabBackground":
            return $customizeCustomThemeViewModel.customTheme.tabLayoutWithCollapsedCollapsingToolbarTabBackground
        case "tabLayoutWithCollapsedCollapsingToolbarTextColor":
            return $customizeCustomThemeViewModel.customTheme.tabLayoutWithCollapsedCollapsingToolbarTextColor
        case "tabLayoutWithCollapsedCollapsingToolbarTabIndicator":
            return $customizeCustomThemeViewModel.customTheme.tabLayoutWithCollapsedCollapsingToolbarTabIndicator
        case "upvoted":
            return $customizeCustomThemeViewModel.customTheme.upvoted
        case "downvoted":
            return $customizeCustomThemeViewModel.customTheme.downvoted
        case "postTypeBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.postTypeBackgroundColor
        case "postTypeTextColor":
            return $customizeCustomThemeViewModel.customTheme.postTypeTextColor
        case "spoilerBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.spoilerBackgroundColor
        case "spoilerTextColor":
            return $customizeCustomThemeViewModel.customTheme.spoilerTextColor
        case "nsfwBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.nsfwBackgroundColor
        case "nsfwTextColor":
            return $customizeCustomThemeViewModel.customTheme.nsfwTextColor
        case "flairBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.flairBackgroundColor
        case "flairTextColor":
            return $customizeCustomThemeViewModel.customTheme.flairTextColor
        case "awardsBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.awardsBackgroundColor
        case "awardsTextColor":
            return $customizeCustomThemeViewModel.customTheme.awardsTextColor
        case "archivedTint":
            return $customizeCustomThemeViewModel.customTheme.archivedTint
        case "lockedIconTint":
            return $customizeCustomThemeViewModel.customTheme.lockedIconTint
        case "crosspostIconTint":
            return $customizeCustomThemeViewModel.customTheme.crosspostIconTint
        case "upvoteRatioIconTint":
            return $customizeCustomThemeViewModel.customTheme.upvoteRatioIconTint
        case "stickiedPostIconTint":
            return $customizeCustomThemeViewModel.customTheme.stickiedPostIconTint
        case "noPreviewPostTypeIconTint":
            return $customizeCustomThemeViewModel.customTheme.noPreviewPostTypeIconTint
        case "subscribed":
            return $customizeCustomThemeViewModel.customTheme.subscribed
        case "unsubscribed":
            return $customizeCustomThemeViewModel.customTheme.unsubscribed
        case "username":
            return $customizeCustomThemeViewModel.customTheme.username
        case "subreddit":
            return $customizeCustomThemeViewModel.customTheme.subreddit
        case "authorFlairTextColor":
            return $customizeCustomThemeViewModel.customTheme.authorFlairTextColor
        case "submitter":
            return $customizeCustomThemeViewModel.customTheme.submitter
        case "moderator":
            return $customizeCustomThemeViewModel.customTheme.moderator
        case "currentUser":
            return $customizeCustomThemeViewModel.customTheme.currentUser
        case "singleCommentThreadBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.singleCommentThreadBackgroundColor
        case "unreadMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.unreadMessageBackgroundColor
        case "dividerColor":
            return $customizeCustomThemeViewModel.customTheme.dividerColor
        case "noPreviewPostTypeBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.noPreviewPostTypeBackgroundColor
        case "voteAndReplyUnavailableButtonColor":
            return $customizeCustomThemeViewModel.customTheme.voteAndReplyUnavailableButtonColor
        case "commentVerticalBarColor1":
            return $customizeCustomThemeViewModel.customTheme.commentVerticalBarColor1
        case "commentVerticalBarColor2":
            return $customizeCustomThemeViewModel.customTheme.commentVerticalBarColor2
        case "commentVerticalBarColor3":
            return $customizeCustomThemeViewModel.customTheme.commentVerticalBarColor3
        case "commentVerticalBarColor4":
            return $customizeCustomThemeViewModel.customTheme.commentVerticalBarColor4
        case "commentVerticalBarColor5":
            return $customizeCustomThemeViewModel.customTheme.commentVerticalBarColor5
        case "commentVerticalBarColor6":
            return $customizeCustomThemeViewModel.customTheme.commentVerticalBarColor6
        case "commentVerticalBarColor7":
            return $customizeCustomThemeViewModel.customTheme.commentVerticalBarColor7
        case "navBarColor":
            return $customizeCustomThemeViewModel.customTheme.navBarColor
        default:
            return nil
        }
    }
    
    private enum FieldType: Hashable {
        case name
    }
}
