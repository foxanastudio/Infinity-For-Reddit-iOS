//
//  UITableViewList.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-22.
//

import SwiftUI
import UIKit

struct UICollectionViewList<Item: Hashable>: UIViewRepresentable {
    let items: [Item]
    let viewForItem: (Item) -> AnyView
    let onItemAppear: ((Int, Item) -> Void)?

    var scrollFromBottom: Bool = false
    @Binding var scrollToBottomTrigger: Bool

    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true

        collectionView.register(UICollectionViewList.HostingCollectionViewCell.self, forCellWithReuseIdentifier: "HostingCell")

        // Add the KVO observer for contentSize
        collectionView.addObserver(context.coordinator, forKeyPath: "contentSize", options: .new, context: nil)

        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.items = items
        context.coordinator.onItemAppear = onItemAppear
        context.coordinator.scrollFromBottom = scrollFromBottom

        let oldItemsCount = uiView.numberOfItems(inSection: 0)
        let newItemsCount = items.count

        if newItemsCount > oldItemsCount {
            // New items added (e.g., send new message)
            uiView.performBatchUpdates({
                let indexPathsToInsert: [IndexPath] = (oldItemsCount..<newItemsCount).map { row in
                    IndexPath(row: row, section: 0)
                }
                uiView.insertItems(at: indexPathsToInsert)
            }) { _ in
                // After batch updates complete, explicitly set the flag to scroll to bottom
                context.coordinator.pendingScrollToBottom = true
            }
        } else if newItemsCount < oldItemsCount {
            // Items removed or fully reloaded (e.g., old messages removed, or initial load of a few items)
            // This is where "load more" at the top might trigger a more complex update
            context.coordinator.prepareForScrollAdjustment(in: uiView) // <--- Capture current state
            uiView.reloadData() // Full reload if items are removed/reordered
            // The KVO observer will pick up the contentSize change from reloadData
            context.coordinator.pendingScrollAdjustment = true // <--- Flag for adjustment
        } else if scrollToBottomTrigger {
            // Initial load or explicit scroll request for existing data
            context.coordinator.pendingScrollToBottom = true
        }

        // Reset the SwiftUI binding trigger immediately, as the KVO will handle the actual scroll
        if scrollToBottomTrigger {
            DispatchQueue.main.async {
                self.scrollToBottomTrigger = false
            }
        }
    }

    static func dismantleUIView(_ uiView: UICollectionView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: "contentSize")
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(items: items, viewForItem: viewForItem, onItemAppear: onItemAppear, scrollFromBottom: scrollFromBottom)
    }

    // MARK: - Coordinator (Nested within UICollectionViewList)
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var items: [Item]
        let viewForItem: (Item) -> AnyView
        var onItemAppear: ((Int, Item) -> Void)?
        var scrollFromBottom: Bool

        // Flags to control scroll behavior in KVO
        var pendingScrollToBottom: Bool = false
        var pendingScrollAdjustment: Bool = false

        // State for scroll adjustment
        var lastContentHeight: CGFloat = 0
        var lastContentOffset: CGPoint = .zero

        init(items: [Item],
             viewForItem: @escaping (Item) -> AnyView,
             onItemAppear: ((Int, Item) -> Void)?,
             scrollFromBottom: Bool
        ) {
            self.items = items
            self.viewForItem = viewForItem
            self.onItemAppear = onItemAppear
            self.scrollFromBottom = scrollFromBottom
            super.init()
        }

        // MARK: - Prepare for Scroll Adjustment (Call BEFORE reloadData/updates for scroll-up scenarios)
        func prepareForScrollAdjustment(in collectionView: UICollectionView) {
            lastContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
            lastContentOffset = collectionView.contentOffset
            print("Preparing for scroll adjustment. Old Content Height: \(lastContentHeight), Old Offset: \(lastContentOffset.y)")
        }

        // MARK: - KVO Observer Method
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard keyPath == "contentSize", let collectionView = object as? UICollectionView else {
                return
            }

            // Always dispatch to main async to avoid re-entrancy issues with layout
            DispatchQueue.main.async {
                // Invalidate and layout to ensure the contentSize is fresh if not already done by UIKit
                // This is less about forcing layout, and more about ensuring its state is current.
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.layoutIfNeeded() // Ensures contentSize is finalized before we read it

                let currentContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height

                // --- Handle Scroll To Bottom (for new messages or initial load) ---
                if self.pendingScrollToBottom {
                    self.pendingScrollToBottom = false // Reset immediately

                    guard collectionView.numberOfSections > 0 else { return }
                    let lastSection = collectionView.numberOfSections - 1
                    let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1

                    if lastItem >= 0 && currentContentHeight > 0 { // Ensure there are items and content has size
                        let indexPath = IndexPath(item: lastItem, section: lastSection)
                        // Use animated: true for new messages, animated: false for initial load might be better
                        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                        print("KVO: Scrolled to bottom. Item: \(lastItem), Content Height: \(currentContentHeight)")
                    }
                    return // Consume the event, no further adjustment needed for this type of scroll
                }

                // --- Handle Scroll Adjustment (for "load more" or other content shifts at top) ---
                if self.pendingScrollAdjustment {
                    self.pendingScrollAdjustment = false // Reset immediately

                    // Calculate the difference in content height
                    let heightDiff = currentContentHeight - self.lastContentHeight
                    print("KVO: Content height changed by \(heightDiff). Old: \(self.lastContentHeight), New: \(currentContentHeight)")

                    if heightDiff > 0 { // If content height increased (e.g., added items at the top)
                        let newOffset = CGPoint(x: self.lastContentOffset.x, y: self.lastContentOffset.y + heightDiff)
                        collectionView.setContentOffset(newOffset, animated: false) // No animation for smooth adjustment
                        print("KVO: Adjusted scroll offset to \(newOffset.y)")
                    }
                    return // Consume the event
                }
            }
        }

        // MARK: - UICollectionViewDataSource

        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return items.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: indexPath) as! UICollectionViewList.HostingCollectionViewCell

            let swiftUIView = viewForItem(items[indexPath.item])
            cell.set(rootView: swiftUIView)

            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            return cell
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.bounds.width
            // Return a minimal height for estimated size; actual height determined by auto-layout
            return CGSize(width: width, height: 1)
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 4
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }

        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            let index = indexPath.item
            guard index < items.count else { return }
            onItemAppear?(index, items[index])
        }
    }

    // MARK: - HostingCollectionViewCell (Nested within UICollectionViewList)
    class HostingCollectionViewCell: UICollectionViewCell {
        private var hostingController: UIHostingController<AnyView>?

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.backgroundColor = .clear
            backgroundColor = .clear
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func set(rootView: AnyView) {
            if hostingController == nil {
                hostingController = UIHostingController(rootView: rootView)
                guard let hcView = hostingController?.view else { return }

                hcView.backgroundColor = .clear
                contentView.backgroundColor = .clear

                hcView.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(hcView)

                NSLayoutConstraint.activate([
                    hcView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    hcView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    hcView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    hcView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                ])
            } else {
                hostingController?.rootView = rootView
                hostingController?.view.setNeedsLayout()
                hostingController?.view.layoutIfNeeded()
            }
        }

        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
            guard let hostingController = hostingController else {
                return super.preferredLayoutAttributesFitting(layoutAttributes)
            }

            let targetAttributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
            let targetSize = CGSize(width: targetAttributes.frame.width, height: UIView.layoutFittingExpandedSize.height)
            let fittingSize = hostingController.view.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )

            targetAttributes.frame.size = fittingSize
            return targetAttributes
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            hostingController?.view.frame = contentView.bounds
        }
    }
}

