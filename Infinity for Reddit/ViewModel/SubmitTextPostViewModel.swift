//
// SubmitTextPostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import Foundation
import MarkdownUI

class SubmitTextPostViewModel: ObservableObject {
    @Published var title: String = ""  
    @Published var content: String = ""
    @Published var selectedAccount: Account
    @Published var selectedFlair: Flair?
    
    init() {
        self.selectedAccount = AccountViewModel.shared.account
    }
}
