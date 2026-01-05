//
//  OnboardingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-01-01.
//

import SwiftUI
import Lottie

struct OnboardingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentIndex = 0
    
    let onFinish: () -> Void
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Reddit, your way",
            subtitle: "Filters, themes, and browsing all in your hands.",
            animation: "RedditYourWay"
        ),
        OnboardingPage(
            title: "Post anything",
            subtitle: "Text, images, videos, GIFs, galleries, links, and polls exactly as you want.",
            animation: "PostAnything"
        ),
        OnboardingPage(
            title: "Browse without limits",
            subtitle: "Subscribe, save, vote, and revisit, even when logged out.",
            animation: "BrowseWithoutLimits"
        )
    ]
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index], primaryTextColor: primaryTextColor, secondaryTextColor: secondaryTextColor)
                            .padding(16)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                PageIndicator(
                    count: pages.count,
                    currentIndex: currentIndex,
                    primaryIndicatorColor: primaryTextColor,
                    secondaryIndicatorColor: secondaryTextColor
                )
                
                Button(action: advance) {
                    Text(currentIndex == pages.count - 1 ? "Get Started" : "Next")
                        .frame(maxWidth: 500)
                }
                .foregroundColor(.white)
                .tint(Color(hex: "#0336FF"))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, proxy.size.height > 1000 ? 120 : 16)
            }
        }
        .animation(.default, value: currentIndex)
        .background(colorScheme == .light ? .white : .black)
    }
    
    private func advance() {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
        } else {
            onFinish()
        }
    }
    
    struct OnboardingPage: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let animation: String
    }
    
    struct OnboardingPageView: View {
        let page: OnboardingPage
        let primaryTextColor: Color
        let secondaryTextColor: Color

        var body: some View {
            VStack(spacing: 24) {
                LottieView(animation: .named(page.animation))
                  .playing()
                  .looping()
                
                Spacer()

                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(primaryTextColor)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
        }
    }
    
    struct PageIndicator: View {
        let count: Int
        let currentIndex: Int
        let primaryIndicatorColor: Color
        let secondaryIndicatorColor: Color

        var body: some View {
            HStack(spacing: 8) {
                ForEach(0..<count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? primaryIndicatorColor : secondaryIndicatorColor)
                        .frame(width: index == currentIndex ? 18 : 6, height: 6)
                        .animation(.easeInOut, value: currentIndex)
                }
            }
            .padding(.bottom, 12)
        }
    }
    
    var primaryTextColor: Color {
        return colorScheme == .light ? Color.black : Color.white
    }
    
    var secondaryTextColor: Color {
        return Color(hex: colorScheme == .light ? "#808080" : "#B3B3B3")
    }
}
