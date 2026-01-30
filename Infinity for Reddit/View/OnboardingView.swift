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
    @State private var animate = false
    
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
            VStack(spacing: 0) {
                TabView(selection: $currentIndex) {
                    WelcomePageView(
                        horizontalLayout: proxy.size.width > proxy.size.height || proxy.size.width > 1400,
                        geoWidth: proxy.size.width,
                        geoHeight: proxy.size.height,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        largeFontSize: proxy.size.width > 500
                    )
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 32)
                    .tag(0)
                    
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            horizontalLayout: proxy.size.width > proxy.size.height || proxy.size.width > 1400,
                            geoHeight: proxy.size.height,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            largeFontSize: proxy.size.width > 500
                        )
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 32)
                        .tag(index + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                PageIndicator(
                    count: pages.count + 1,
                    currentIndex: currentIndex,
                    primaryIndicatorColor: primaryTextColor,
                    secondaryIndicatorColor: secondaryTextColor
                )
                
                Button(action: advance) {
                    Text(currentIndex == 0 ? "Take a Quick Tour" : currentIndex == pages.count ? "Get Started" : "Next")
                        .frame(maxWidth: 500)
                }
                .foregroundColor(.white)
                .tint(Color(hex: "#0336FF"))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .padding(.bottom, proxy.size.height > 1000 ? 120 : 16)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.25), value: animate)
            }
            .background(.ultraThinMaterial)
        }
        .animation(.default, value: currentIndex)
        .background {
            SwiftUI.Image("onboarding_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .onAppear {
            animate = true
        }
    }
    
    private func advance() {
        if currentIndex < pages.count {
            currentIndex += 1
        } else {
            onFinish()
        }
    }
    
    struct WelcomePageView: View {
        @State private var animate = false
        
        let horizontalLayout: Bool
        let geoWidth: CGFloat
        let geoHeight: CGFloat
        let primaryTextColor: Color
        let secondaryTextColor: Color
        let largeFontSize: Bool
        
        var body: some View {
            if horizontalLayout && geoHeight < 500 {
                HStack(spacing: 24) {
                    SwiftUI.Image("onboarding_app_icon")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .scaleEffect(animate ? 1 : 0.9)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.4), value: animate)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RowText("Welcome to Infinity for Reddit!")
                            .font(.system(size: 24))
                            .foregroundStyle(secondaryTextColor)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 10)
                            .animation(.easeOut(duration: 0.4).delay(0.15), value: animate)
                        
                        RowText("The infinitely better Reddit experience.")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(primaryTextColor)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 10)
                            .animation(.easeOut(duration: 0.4).delay(0.15), value: animate)
                    }
                    .frame(maxWidth: .infinity)
                }
                .onAppear {
                    animate = true
                }
            } else {
                ZStack {
                    VStack(alignment: .leading, spacing: 24) {
                        SwiftUI.Image("onboarding_app_icon")
                            .resizable()
                            .frame(width: min(geoWidth / 3, 200), height: min(geoWidth / 3, 200))
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .scaleEffect(animate ? 1 : 0.9)
                            .opacity(animate ? 1 : 0)
                            .animation(.easeOut(duration: 0.4), value: animate)
                        
                        Spacer()
                        
                        Text("Welcome to Infinity for Reddit!")
                            .font(.system(size: 32))
                            .foregroundStyle(secondaryTextColor)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 10)
                            .animation(.easeOut(duration: 0.4).delay(0.15), value: animate)
                        
                        RowText("The infinitely better Reddit experience.")
                            .font(.system(size: largeFontSize ? 72 : 48, weight: .bold))
                            .foregroundStyle(primaryTextColor)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 10)
                            .animation(.easeOut(duration: 0.4).delay(0.15), value: animate)
                        
                        if horizontalLayout {
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    animate = true
                }
            }
        }
    }
    
    struct OnboardingPageView: View {
        let page: OnboardingPage
        let horizontalLayout: Bool
        let geoHeight: CGFloat
        let primaryTextColor: Color
        let secondaryTextColor: Color
        let largeFontSize: Bool

        var body: some View {
            if horizontalLayout && geoHeight < 500 {
                HStack(spacing: 24) {
                    LottieView(animation: .named(page.animation))
                        .playing()
                        .looping()
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 24) {
                        Text(page.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(primaryTextColor)
                            .multilineTextAlignment(.center)

                        Text(page.subtitle)
                            .foregroundStyle(secondaryTextColor)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
            } else {
                VStack(spacing: 24) {
                    Spacer()
                    
                    LottieView(animation: .named(page.animation))
                      .playing()
                      .looping()
                    
                    Spacer()

                    Text(page.title)
                        .font(.system(size: largeFontSize ? 56 : 32, weight: .bold))
                        .foregroundStyle(primaryTextColor)
                        .multilineTextAlignment(.center)

                    Text(page.subtitle)
                        .font(.system(size: largeFontSize ? 32 : 17))
                        .foregroundStyle(secondaryTextColor)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
            }
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
    
    struct OnboardingPage: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let animation: String
    }
}
