//
//  SubmitCommentViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-17.
//

import Foundation
import MarkdownUI

class SubmitCommentViewModel: ObservableObject {
    @Published var selectedAccount: Account
    @Published var text: String = ""
    
    let commentParent: CommentParent
    
    init(commentParent: CommentParent) {
        self.selectedAccount = AccountViewModel.shared.account
        self.commentParent = commentParent
    }
}
