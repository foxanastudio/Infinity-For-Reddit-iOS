//
//  ModMailParticipantsView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-28.
//

import SwiftUI

struct ModMailParticipantsView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    let participantDisplayNames: [ModMailParticipantDisplayName]
    let messageCount: Int
    
    var body: some View {
        HStack(spacing: 0) {
            if participantDisplayNames.isEmpty {
                Text("-")
                    .secondaryText()
            }
            
            ForEach(Array(participantDisplayNames.enumerated()), id: \.offset) { index, participantDisplayName in
                if index > 0 {
                    Text(", ")
                        .secondaryText()
                }
                
                if participantDisplayName.isSubreddit {
                    Text(participantDisplayName.name)
                        .subreddit()
                } else if participantDisplayName.isModerator {
                    Text(participantDisplayName.name)
                        .customFont()
                        .foregroundColor(Color(hex: customThemeViewModel.currentCustomTheme.moderator))
                        .lineLimit(1)
                } else {
                    Text(participantDisplayName.name)
                        .username()
                }
            }
            
            if messageCount > 1 {
                Text("\(messageCount)")
                    .secondaryText()
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.leading, 8)
            }
        }
    }
}
