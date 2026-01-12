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
    
    init(customThemeId: Int?, predefindCustomThemeName: String?) {
        _customizeCustomThemeViewModel = StateObject(
            wrappedValue: CustomizeCustomThemeViewModel(
                customThemeId: customThemeId,
                predefindCustomThemeName: predefindCustomThemeName,
                customizeCustomThemeRepository: CustomizeCustomThemeRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            if customizeCustomThemeViewModel.backingCustomTheme == nil {
                ZStack {
                    switch customizeCustomThemeViewModel.loadState {
                    case .failed(let error):
                        Text("Unable to load theme. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                    default:
                        ProgressIndicator()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    ScrollView {
                        LazyVStack {
                            VStack(alignment: .leading, spacing: 0) {
                                CustomTextField(
                                    "Name",
                                    text: $customizeCustomThemeViewModel.customTheme.name,
                                    singleLine: true,
                                    fieldType: FieldType.name,
                                    focusedField: $focusedField
                                )
                                .submitLabel(.done)
                                .padding(16)
                                
                                CustomDivider()
                            }
                            .limitedWidthListItem()
                            
                            ForEach(customizeCustomThemeViewModel.customThemeFields, id: \.self) { fieldName in
                                if customizeCustomThemeViewModel.customThemeFieldsBoolType.contains(fieldName) {
                                    if let binding = getBooleanBinding(for: fieldName) {
                                        BooleanEntry(
                                            fieldName: fieldName,
                                            title: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.title ?? "",
                                            isEnabled: binding
                                        )
                                        .limitedWidthListItem()
                                    }
                                } else {
                                    if let colorIntBinding = getColorIntBinding(for: fieldName), let colorBinding = getColorBinding(for: fieldName) {
                                        ColorEntry(
                                            colorInt: colorIntBinding,
                                            color: colorBinding,
                                            fieldName: fieldName,
                                            title: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.title ?? "",
                                            description: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.description ?? ""
                                        )
                                        .limitedWidthListItem()
                                    }
                                }
                            }
                        }
                    }
                    
                    KeyboardToolbar {
                        focusedField = nil
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if customizeCustomThemeViewModel.backingCustomTheme != nil {
                    Button(action: {
                        customizeCustomThemeViewModel.saveCustomTheme()
                    }) {
                        SwiftUI.Image(systemName: "tray.and.arrow.down")
                            .navigationBarImage()
                    }
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Customize")
        .onChange(of: customizeCustomThemeViewModel.savingSuccess) { _, newValue in
            if newValue {
                dismiss()
            }
        }
        .showErrorUsingSnackbar(customizeCustomThemeViewModel.$error)
        .task {
            await customizeCustomThemeViewModel.getAndSetCustomTheme()
        }
    }
    
    private struct ColorEntry: View {
        @Binding var colorInt: Int
        @Binding var color: Color
        
        let fieldName: String
        let title: String
        let description: String
        
        init(colorInt: Binding<Int>, color: Binding<Color>, fieldName: String, title: String, description: String) {
            _colorInt = colorInt
            _color = color
            self.fieldName = fieldName
            self.title = title
            self.description = description
        }
        
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
                        get: {
                            color
                        },
                        set: { newColor in
                            color = newColor
                            colorInt = newColor.toHex()
                        }
                    ))
                    .frame(width: 24, height: 24)
                    .padding(.vertical, 16)
                    .padding(.trailing, 16)
                    .labelsHidden()
                }
                .frame(maxWidth: .infinity)
                
                CustomDivider()
            }
        }
    }
    
    private struct BooleanEntry: View {
        let fieldName: String
        let title: String
        let isEnabled: Binding<Bool>
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text(title)
                        .primaryText()
                        .padding(16)
                    
                    Spacer()
                    
                    Toggle(isOn: isEnabled) {}
                        .padding(.vertical, 16)
                        .padding(.trailing, 16)
                        .labelsHidden()
                        .themedToggle()
                }
                .frame(maxWidth: .infinity)
                
                CustomDivider()
            }
        }
    }
    
    private func getBooleanBinding(for fieldName: String) -> Binding<Bool>? {
        switch fieldName {
        case "isLightTheme":
            return $customizeCustomThemeViewModel.customTheme.isLightTheme
        case "isDarkTheme":
            return $customizeCustomThemeViewModel.customTheme.isDarkTheme
        case "isAmoledTheme":
            return $customizeCustomThemeViewModel.customTheme.isAmoledTheme
        default:
            return nil
        }
    }
    
    private func getColorIntBinding(for fieldName: String) -> Binding<Int>? {
        switch fieldName {
        case "colorPrimary":
            return $customizeCustomThemeViewModel.customTheme.colorPrimary
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
        case "linkColor":
            return $customizeCustomThemeViewModel.customTheme.linkColor
        case "receivedMessageTextColor":
            return $customizeCustomThemeViewModel.customTheme.receivedMessageTextColor
        case "sentMessageTextColor":
            return $customizeCustomThemeViewModel.customTheme.sentMessageTextColor
        case "switchColor":
            return $customizeCustomThemeViewModel.customTheme.switchColor
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
        case "receivedMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.receivedMessageBackgroundColor
        case "sentMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.sentMessageBackgroundColor
        case "tabBarBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.tabBarBackgroundColor
        case "snackbarTextColor":
            return $customizeCustomThemeViewModel.customTheme.snackbarTextColor
        case "snackbarActionTextColor":
            return $customizeCustomThemeViewModel.customTheme.snackbarActionTextColor
        case "snackbarBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.snackbarBackgroundColor
        case "primaryIconColor":
            return $customizeCustomThemeViewModel.customTheme.primaryIconColor
        case "tabBarTextAndIconColor":
            return $customizeCustomThemeViewModel.customTheme.tabBarTextAndIconColor
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
        case "mediaIndicatorIconColor":
            return $customizeCustomThemeViewModel.customTheme.mediaIndicatorIconColor
        case "mediaIndicatorBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.mediaIndicatorBackgroundColor
        case "pickerItemTextColor":
            return $customizeCustomThemeViewModel.customTheme.pickerItemTextColor
        case "pickerSelectedItemTextColor":
            return $customizeCustomThemeViewModel.customTheme.pickerSelectedItemTextColor
        case "pickerSelectedItemBackgroundColor":
            return $customizeCustomThemeViewModel.customTheme.pickerSelectedItemBackgroundColor
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
        default:
            return nil
        }
    }
    
    private func getColorBinding(for fieldName: String) -> Binding<Color>? {
        switch fieldName {
        case "colorPrimary":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.colorPrimary
        case "colorAccent":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.colorAccent
        case "colorPrimaryLightTheme":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.colorPrimaryLightTheme
        case "primaryTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.primaryTextColor
        case "secondaryTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.secondaryTextColor
        case "postTitleColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.postTitleColor
        case "postContentColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.postContentColor
        case "readPostTitleColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.readPostTitleColor
        case "readPostContentColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.readPostContentColor
        case "commentColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentColor
        case "buttonTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.buttonTextColor
        case "linkColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.linkColor
        case "receivedMessageTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.receivedMessageTextColor
        case "sentMessageTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.sentMessageTextColor
        case "switchColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.switchColor
        case "backgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.backgroundColor
        case "cardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.cardViewBackgroundColor
        case "readPostCardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.readPostCardViewBackgroundColor
        case "filledCardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.filledCardViewBackgroundColor
        case "readPostFilledCardViewBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.readPostFilledCardViewBackgroundColor
        case "commentBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentBackgroundColor
        case "fullyCollapsedCommentBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.fullyCollapsedCommentBackgroundColor
        case "receivedMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.receivedMessageBackgroundColor
        case "sentMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.sentMessageBackgroundColor
        case "tabBarBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.tabBarBackgroundColor
        case "snackbarTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.snackbarTextColor
        case "snackbarActionTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.snackbarActionTextColor
        case "snackbarBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.snackbarBackgroundColor
        case "primaryIconColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.primaryIconColor
        case "tabBarTextAndIconColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.tabBarTextAndIconColor
        case "postIconAndInfoColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.postIconAndInfoColor
        case "commentIconAndInfoColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentIconAndInfoColor
        case "fabIconColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.fabIconColor
        case "sendMessageIconColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.sendMessageIconColor
        case "toolbarPrimaryTextAndIconColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.toolbarPrimaryTextAndIconColor
        case "mediaIndicatorIconColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.mediaIndicatorIconColor
        case "mediaIndicatorBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.mediaIndicatorBackgroundColor
        case "pickerItemTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.pickerItemTextColor
        case "pickerSelectedItemTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.pickerSelectedItemTextColor
        case "pickerSelectedItemBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.pickerSelectedItemBackgroundColor
        case "upvoted":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.upvoted
        case "downvoted":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.downvoted
        case "postTypeBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.postTypeBackgroundColor
        case "postTypeTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.postTypeTextColor
        case "spoilerBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.spoilerBackgroundColor
        case "spoilerTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.spoilerTextColor
        case "nsfwBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.nsfwBackgroundColor
        case "nsfwTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.nsfwTextColor
        case "flairBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.flairBackgroundColor
        case "flairTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.flairTextColor
        case "archivedTint":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.archivedTint
        case "lockedIconTint":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.lockedIconTint
        case "crosspostIconTint":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.crosspostIconTint
        case "upvoteRatioIconTint":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.upvoteRatioIconTint
        case "stickiedPostIconTint":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.stickiedPostIconTint
        case "noPreviewPostTypeIconTint":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.noPreviewPostTypeIconTint
        case "subscribed":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.subscribed
        case "unsubscribed":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.unsubscribed
        case "username":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.username
        case "subreddit":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.subreddit
        case "authorFlairTextColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.authorFlairTextColor
        case "submitter":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.submitter
        case "moderator":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.moderator
        case "currentUser":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.currentUser
        case "singleCommentThreadBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.singleCommentThreadBackgroundColor
        case "unreadMessageBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.unreadMessageBackgroundColor
        case "dividerColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.dividerColor
        case "noPreviewPostTypeBackgroundColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.noPreviewPostTypeBackgroundColor
        case "voteAndReplyUnavailableButtonColor":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.voteAndReplyUnavailableButtonColor
        case "commentVerticalBarColor1":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentVerticalBarColor1
        case "commentVerticalBarColor2":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentVerticalBarColor2
        case "commentVerticalBarColor3":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentVerticalBarColor3
        case "commentVerticalBarColor4":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentVerticalBarColor4
        case "commentVerticalBarColor5":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentVerticalBarColor5
        case "commentVerticalBarColor6":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentVerticalBarColor6
        case "commentVerticalBarColor7":
            return $customizeCustomThemeViewModel.customThemeSettingsColorModel.commentVerticalBarColor7
        default:
            return nil
        }
    }
    
    private enum FieldType: Hashable {
        case name
    }
}
