//
//  ReportView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-23.
//

import SwiftUI
import MarkdownUI

struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject var reportViewModel: ReportViewModel
    
    init(subredditName: String, thingFullname: String) {
        _reportViewModel = StateObject(
            wrappedValue: ReportViewModel(
                subredditName: subredditName,
                thingFullname: thingFullname,
                reportRepository: ReportRepository(),
                ruleRepository: RuleRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(reportViewModel.siteReasons, id: \.self) { reason in
                        ReasonItemView(reason: reason, description: nil, isSelected: reportViewModel.isSelected(reason: reason)) {
                            reportViewModel.selectSiteReason(reason)
                        }
                    }
                    
                    ForEach(reportViewModel.rules, id: \.shortName) { rule in
                        ReasonItemView(reason: rule.shortName, description: rule.description, isSelected: reportViewModel.isSelected(rule: rule)) {
                            reportViewModel.selectRuleReason(rule)
                        }
                    }
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Report")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if reportViewModel.selectedReportReason != nil {
                    Button(action: {
                        reportViewModel.report()
                    }) {
                        SwiftUI.Image(systemName: "checkmark.circle")
                            .navigationBarImage()
                    }
                }
            }
        }
        .task {
            await reportViewModel.fetchRules()
        }
        .onChange(of: reportViewModel.reportTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Reporting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: reportViewModel.reportSubmitted) { _, newValue in
            if newValue {
                snackbarManager.showSnackbar(.info("Reported"))
                dismiss()
            }
        }
        .showErrorUsingSnackbar(reportViewModel.$error)
    }
    
    struct ReasonItemView: View {
        @EnvironmentObject private var navigationManager: NavigationManager
        @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
        
        @State private var showDescription: Bool = false
        
        let reason: String
        let description: String?
        let isSelected: Bool
        let toggleSelection: () -> Void
        
        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                SwiftUI.Image(systemName: isSelected ? "checkmark.square" : "square")
                    .primaryIcon()
                
                Spacer()
                    .frame(width: 24)
                
                VStack(spacing: 8) {
                    RowText(reason)
                        .primaryText()
                    
                    if let description, showDescription {
                        Markdown(description)
                            .themedMarkdown()
                            .markdownLinkHandler { url in
                                navigationManager.openLink(url)
                            }
                    }
                }
                
                
                if description != nil {
                    Spacer()
                        .frame(width: 24)
                    
                    SwiftUI.Image(systemName: "chevron.down.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .primaryIcon()
                        .rotationEffect(.degrees(showDescription ? 180 : 0))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                showDescription.toggle()
                            }
                        }
                }
            }
            .padding(16)
            .background(isSelected ? Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor) : Color.clear)
            .onTapGesture(perform: toggleSelection)
        }
    }
}
