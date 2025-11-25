//
//  PostModerationSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-24.
//

import SwiftUI

struct PostModerationSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let post: Post
    
    let onApprove: () -> Void
    let onRemove: () -> Void
    let onMarkAsSpam: () -> Void
    let onToggleStickyPost: () -> Void
    let onToggleLock: () -> Void
    let onToggleSensitive: () -> Void
    let onToggleSpoiler: () -> Void
    let onToggleDistinguishAsModerator: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Moderate")
                    .primaryText()
                
                Spacer()
                    .frame(height: 16)
                
                if !post.approved {
                    IconTextButton(startIconUrl: "checkmark.shield.fill", text: "Approve") {
                        onApprove()
                        dismiss()
                    }
                }
                
                if !post.removed {
                    IconTextButton(startIconUrl: "xmark", text: "Remove") {
                        onRemove()
                        dismiss()
                    }
                    
                    IconTextButton(startIconUrl: "trash", text: "Mark as spam") {
                        onMarkAsSpam()
                        dismiss()
                    }
                }
                
                IconTextButton(startIconUrl: post.stickied ? "pin.slash" : "pin", text: "\(post.stickied ? "Unstick" : "Stick") post") {
                    onToggleStickyPost()
                    dismiss()
                }
                
                IconTextButton(startIconUrl: post.locked ? "lock.open.fill" : "lock.fill", text: post.locked ? "Unlock" : "Lock") {
                    onToggleLock()
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "eye.trianglebadge.exclamationmark", text: "\(post.over18 ? "Unmark" : "Mark") sensitive") {
                    onToggleSensitive()
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "exclamationmark.triangle.fill", text: "\(post.spoiler ? "Unmark" : "Mark") spoiler") {
                    onToggleSpoiler()
                    dismiss()
                }
                
                IconTextButton(startIconUrl: post.isModerator ? "shield.slash" : "shield", text: "\(post.isModerator ? "Undistinguish" : "Distinguish") as moderator") {
                    onToggleDistinguishAsModerator()
                    dismiss()
                }
            }
            .padding(.top, 24)
        }
    }
}
