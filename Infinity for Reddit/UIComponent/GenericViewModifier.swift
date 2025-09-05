//
//  GenericViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-14.
//

import SwiftUI

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
                            switch post?.postType {
                            case .image:
                                fullScreenMediaViewModel.show(.image(url: post?.url ?? "", aspectRatio: aspectRatio, post: post, matchedGeometryEffectId: matchedGeometryEffectId))
                            case .imageWithUrlPreview(let urlPreview):
                                fullScreenMediaViewModel.show(.image(url: post?.url ?? "", aspectRatio: aspectRatio, post: post, matchedGeometryEffectId: matchedGeometryEffectId))
                            case .gif:
                                print("gif")
                                if post?.preview.images.isEmpty == false {
                                    if let previewImage = post?.preview.images.first {
                                        if let mp4 = previewImage.mp4Variant {
                                            fullScreenMediaViewModel.show(.video(url: mp4.source.url, post: post))
                                        } else if let gif = previewImage.gifVariant {
                                            fullScreenMediaViewModel.show(.gif(url: gif.source.url, post: post))
                                        }
                                    } else {
                                        fullScreenMediaViewModel.show(.gif(url: post?.url ?? "", post: post))
                                    }
                                }
                            case .video(let videoUrl, let downloadUrl):
                                fullScreenMediaViewModel.show(.video(url: videoUrl, post: post))
                            case .link:
                                if let urlString = post?.url, let url = URL(string: urlString) {
                                    //UIApplication.shared.open(url)
                                    LinkHandler.shared.handle(url: url)
                                } else {
                                    print("Invalid or empty URL")
                                }
                                print("link")
                            case .imgurVideo(let url):
                                print("gif")
                            case .redgifs(let redgifsId):
                                print("redgifs")
                            case .streamable(let shortCode):
                                print("streamable")
                            default:
                                print(post?.postType ?? "other types")
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
    
    let onAppEntersForeground: () -> Void
    let onAppEntersBackground: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .background, .inactive:
                    onAppEntersBackground()
                case .active:
                    onAppEntersForeground()
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
