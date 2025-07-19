//
//  MultiColumnList.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-22.
//

import UIKit
import SwiftUI

struct MultiColumnList<Item>: UIViewRepresentable {
    let items: [Item]
    let viewForItem: (Item) -> AnyView

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.dataSource = context.coordinator
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        context.coordinator.items = items
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(items: items, viewForItem: viewForItem)
    }

    class Coordinator: NSObject, UITableViewDataSource {
        var items: [Item]
        let viewForItem: (Item) -> AnyView

        init(items: [Item], viewForItem: @escaping (Item) -> AnyView) {
            self.items = items
            self.viewForItem = viewForItem
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            items.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell") ??
                UITableViewCell(style: .default, reuseIdentifier: "HostingCell")

            // Remove previous hosted views
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            // Lazily create the view for this item
            let swiftUIView = viewForItem(items[indexPath.row])
            let hostingController = UIHostingController(rootView: swiftUIView)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false

            cell.contentView.addSubview(hostingController.view)
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            ])

            return cell
        }
    }
}
