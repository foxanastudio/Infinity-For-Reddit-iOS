//
//  ReportViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-23.
//

import Foundation

class ReportViewModel: ObservableObject {
    private let subredditName: String
    private let thingFullname: String
    private let reportRepository: ReportRepositoryProtocol
    
    init(subredditName: String, thingFullname: String, reportRepository: ReportRepositoryProtocol) {
        self.subredditName = subredditName
        self.thingFullname = thingFullname
        self.reportRepository = reportRepository
    }
}
