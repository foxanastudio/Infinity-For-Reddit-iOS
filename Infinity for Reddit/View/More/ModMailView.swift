//
//  ModMailView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-01.
//

import SwiftUI
import SwiftyJSON

struct ModMailView: View {
    @State private var isLoading = true
    @State private var modMailResponse = "Loading Mod Mail..."

    private let modMailListingRepository: ModMailListingRepositoryProtocol = ModMailListingRepository()
    
    var body: some View {
        ScrollView {
            Text(modMailResponse)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        }
        .task {
            guard isLoading else {
                return
            }

            await loadModMail()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Mod Mail")
    }
    
    private func loadModMail() async {
        do {
            let json = try await modMailListingRepository.fetchModMailListing(
                queries: [
                    "state": "all",
                    "sort": "recent"
                ],
                interceptor: nil
            )
            modMailResponse = json.rawString() ?? "Unable to render Mod Mail JSON."
        } catch {
            modMailResponse = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
