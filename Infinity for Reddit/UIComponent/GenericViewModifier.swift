//
//  GenericViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-14.
//

import SwiftUI
import Combine
import Alamofire

struct NoPreviewPostTypeIndicatorBackgroundViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, minHeight: 96)
            .padding(.horizontal, 16)
            .background(Color(hex: themeViewModel.currentCustomTheme.noPreviewPostTypeBackgroundColor))
    }
}

struct NoPreviewPostTypeIndicatorViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.noPreviewPostTypeIconTint))
    }
}

struct MediaTapGestureHandlerViewModifer: ViewModifier {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    let post: Post?
    let aspectRatio: CGSize?
    let matchedGeometryEffectId: String?
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .highPriorityGesture(
                TapGesture()
                    .onEnded {
                        withAnimation {
                            if let post {
                                switch post.postType {
                                case .image:
                                    fullScreenMediaViewModel.show(.image(urlString: post.url, aspectRatio: aspectRatio, post: post, fileName: "\(post.fileNameWithoutExtension).jpg", matchedGeometryEffectId: matchedGeometryEffectId))
                                case .imageWithUrlPreview(let urlPreview):
                                    fullScreenMediaViewModel.show(.image(urlString: urlPreview, aspectRatio: aspectRatio, post: post, fileName: "\(post.fileNameWithoutExtension).jpg", matchedGeometryEffectId: matchedGeometryEffectId))
                                case .gif:
                                    if post.preview.images.isEmpty == false {
                                        if let previewImage = post.preview.images.first {
                                            if let mp4 = previewImage.mp4Variant {
                                                fullScreenMediaViewModel.show(.video(urlString: mp4.source.url, post: post))
                                            } else if let gif = previewImage.gifVariant {
                                                fullScreenMediaViewModel.show(.gif(urlString: gif.source.url, post: post, fileName: "\(post.fileNameWithoutExtension).gif"))
                                            }
                                        } else {
                                            fullScreenMediaViewModel.show(.gif(urlString: post.url, post: post, fileName: "\(post.fileNameWithoutExtension).gif"))
                                        }
                                    }
                                case .redditVideo(let videoUrlString, _):
                                    fullScreenMediaViewModel.show(.video(urlString: videoUrlString, post: post))
                                case .video(let videoUrlString, _):
                                    fullScreenMediaViewModel.show(.video(urlString: videoUrlString, post: post))
                                case .gallery:
                                    if let items = post.galleryData?.items, let firstGalleryItem = items.first {
                                        fullScreenMediaViewModel.show(.gallery(currentUrlString: firstGalleryItem.urlString, post: post, items: items, galleryScrollState: GalleryScrollState(scrollId: 0)))
                                    }
                                case .imgurVideo(let urlString):
                                    fullScreenMediaViewModel.show(.video(urlString: urlString, videoType: .direct))
                                case .redgifs(let redgifsId):
                                    fullScreenMediaViewModel.show(.video(urlString: post.url, videoType: .redgifs(id: redgifsId)))
                                case .streamable(let shortCode):
                                    fullScreenMediaViewModel.show(.video(urlString: post.url, videoType: .streamable(shortCode: shortCode)))
                                default:
                                    navigationManager.openLink(post.url)
                                }
                            }
                        }
                    }
            )
    }
}

struct PostTypeTagViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(Color(hex: themeViewModel.currentCustomTheme.postTypeBackgroundColor))
            .cornerRadius(4)
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.postTypeTextColor))
            .font(.system(size: 12))
    }
}

struct SpoilerTagViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(Color(hex: themeViewModel.currentCustomTheme.spoilerBackgroundColor))
            .cornerRadius(6)
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.spoilerTextColor))
            .font(.system(size: 12))
    }
}

struct SensitiveTagViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(Color(hex: themeViewModel.currentCustomTheme.nsfwBackgroundColor))
            .cornerRadius(4)
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.nsfwTextColor))
            .font(.system(size: 12))
    }
}

struct PostFlairBackgroundViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .background(Color(hex: themeViewModel.currentCustomTheme.flairBackgroundColor))
            .cornerRadius(4)
    }
}

struct PostFlairTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.flairTextColor))
            .font(.system(size: 12))
    }
}

struct UpvoteRatioTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.secondaryTextColor))
            .font(.system(size: 12))
    }
}

struct UpvoteRatioIconViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.upvoteRatioIconTint))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.upvoteRatioIconTint))
    }
}

struct ArchivedTagViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.archivedTint))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.archivedTint))
    }
}

struct LockedTagViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.lockedIconTint))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.lockedIconTint))
    }
}

struct CrosspostTagViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.crosspostIconTint))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.crosspostIconTint))
    }
}

struct FilledCardBackgroundViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .background(Color(hex: themeViewModel.currentCustomTheme.filledCardViewBackgroundColor))
    }
}

struct AppForegroundBackgroundViewModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    
    let onAppEntersForeground: (() -> Void)?
    let onAppEntersInactive: (() -> Void)?
    let onAppEntersBackground: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .background:
                    onAppEntersBackground?()
                case .inactive:
                    onAppEntersInactive?()
                case .active:
                    onAppEntersForeground?()
                @unknown default: break
                }
            }
    }
}

struct RootViewBackgroundViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .background(Color(hex: themeViewModel.currentCustomTheme.backgroundColor))
    }
}

struct AuthorFlairTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.authorFlairTextColor))
            .font(.system(size: 12))
    }
}

struct VisiblePercentageModifier: ViewModifier {
    let onChange: (CGFloat) -> Void
    let space: CoordinateSpace

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: VisiblePercentageKey.self,
                        value: calculate(proxy: proxy)
                    )
                }
            )
            .onPreferenceChange(VisiblePercentageKey.self, perform: onChange)
    }

    private func calculate(proxy: GeometryProxy) -> CGFloat {
        let frame = proxy.frame(in: space)
        let containerHeight = UIScreen.main.bounds.height

        let visibleTop = max(frame.minY, 0)
        let visibleBottom = min(frame.maxY, containerHeight)

        let visibleHeight = max(0, visibleBottom - visibleTop)
        let percent = visibleHeight / frame.height

        return min(max(percent, 0), 1)
    }
}

struct VisiblePercentageKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SnackbarErrorViewModifier<P: Publisher>: ViewModifier where P.Output == Error?, P.Failure == Never {
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    let errorPublisher: P
    let showTaskCancelledError: Bool
    
    func body(content: Content) -> some View {
        content
            .onReceive(errorPublisher) { newValue in
                if let newValue {
                    if !showTaskCancelledError {
                        if let afError = newValue as? AFError, case .explicitlyCancelled = afError {
                            return
                        } else if newValue is CancellationError {
                            return
                        }
                    }
                    snackbarManager.showSnackbar(.error(newValue))
                } else {
                    snackbarManager.dismiss()
                }
            }
    }
}
