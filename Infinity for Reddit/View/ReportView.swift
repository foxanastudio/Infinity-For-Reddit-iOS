//
//  ReportView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-23.
//

import SwiftUI

struct ReportView: View {
    @StateObject var reportViewModel: ReportViewModel
    
    init(subredditName: String, thingFullname: String) {
        _reportViewModel = StateObject(
            wrappedValue: ReportViewModel(
                subredditName: subredditName, thingFullname: thingFullname, reportRepository: ReportRepository()
            )
        )
    }
    
    var body: some View {
        EmptyView()
    }
}
