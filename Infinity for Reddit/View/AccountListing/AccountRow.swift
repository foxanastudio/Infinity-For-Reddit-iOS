//
//  AccountRow.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-01-22.
//  
import SwiftUI

struct AccountRow: View {
    @Environment(\.dismiss) var dismiss
    var dismissAccountSheet: () -> Void
    @State var account: Account
    let isCurrent: Bool
    
    var body: some View {
        HStack {
            SwiftUI.Image(systemName: account.isAnonymous() ? "person.crop.circle.badge.questionmark" : "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)

            Text(account.username)
                .font(.headline)

            Spacer()

            if isCurrent {
                SwiftUI.Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .onTapGesture {
            do {
                AccountViewModel.shared.switchAccount(newAccount: account)
                try AccountViewModel.shared.updateTokens(accessToken: account.accessToken ?? "", refreshToken: account.refreshToken ?? "")
                dismissAccountSheet()
                dismiss()
            }
            catch{
                print("Error: switching account failed")
            }
        }
    }
}

// Helper for custom rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
