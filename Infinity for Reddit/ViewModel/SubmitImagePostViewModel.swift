//
// SubmitImagePostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-09-24
        
import Foundation
import MarkdownUI

class SubmitImagePostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedAccount: Account
    
    init() {
        self.selectedAccount = AccountViewModel.shared.account
    }
}

