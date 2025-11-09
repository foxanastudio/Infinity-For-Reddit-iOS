//
//  CommentSubmissionShareableViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-22.
//

import Foundation

class CommentSubmissionShareableViewModel: ObservableObject {
    @Published var submittedComment: Comment? = nil
    @Published var editedComment: Comment? = nil
}
