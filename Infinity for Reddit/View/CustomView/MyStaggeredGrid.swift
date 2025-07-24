//
//  MyStaggeredGrid.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-19.
//

import UIKit
import SwiftUI

//extension View {
//    func eraseToAnyView() -> AnyView {
//        AnyView(self)
//    }
//}
//
//// MARK: - 2. HostingCollectionViewCell
//
//class HostingCollectionViewCell: UICollectionViewCell {
//    private var hostingController: UIHostingController<AnyView>?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.backgroundColor = .clear
//        print("Cell \(ObjectIdentifier(self)): Initialized.")
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func host(view: AnyView) {
//        if hostingController == nil {
//            hostingController = UIHostingController(rootView: view)
//            guard let hcView = hostingController?.view else { return }
//
//            hcView.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview(hcView)
//
//            NSLayoutConstraint.activate([
//                hcView.topAnchor.constraint(equalTo: contentView.topAnchor),
//                hcView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//                hcView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//                hcView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//            ])
//            print("Cell \(ObjectIdentifier(self)): Created new UIHostingController for view.")
//        } else {
//            hostingController?.rootView = view
//            print("Cell \(ObjectIdentifier(self)): Updated existing UIHostingController's rootView.")
//        }
//        
//        hostingController?.view.setNeedsLayout()
//        hostingController?.view.layoutIfNeeded()
//        print("Cell \(ObjectIdentifier(self)): Forced layoutIfNeeded on hosted view. Current frame: \(hostingController?.view.frame ?? .zero)")
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        hostingController?.rootView = AnyView(EmptyView())
//        print("Cell \(ObjectIdentifier(self)): prepareForReuse - Resetting hosted view.")
//    }
//    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        
//        let targetSize = CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingExpandedSize.height)
//        let fittingSize = hostingController?.view.systemLayoutSizeFitting(
//            targetSize,
//            withHorizontalFittingPriority: .required,
//            verticalFittingPriority: .fittingSizeLevel
//        ) ?? layoutAttributes.size
//        
//        layoutAttributes.frame.size = fittingSize
//        print("Cell \(ObjectIdentifier(self)): preferredLayoutAttributesFitting - measured size \(fittingSize) for width \(layoutAttributes.frame.width).")
//        return layoutAttributes
//    }
//}
//
//// MARK: - 3. StaggeredGridLayout (Custom UICollectionViewLayout)
//
//protocol StaggeredGridLayoutDelegate: AnyObject {
//    func staggeredGridLayout(_ layout: StaggeredGridLayout, heightForItemAtIndexPath indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat
//}
//
//class StaggeredGridLayout: UICollectionViewLayout {
//    
//    weak var delegate: StaggeredGridLayoutDelegate?
//    var columns: Int
//    var spacing: CGFloat
//    var sectionInsets: UIEdgeInsets
//
//    private var cache: [UICollectionViewLayoutAttributes] = []
//    private var columnHeights: [CGFloat] = []
//    private var currentLayoutContentWidth: CGFloat = 0
//
//    init(columns: Int, spacing: CGFloat = 8, sectionInsets: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8), delegate: StaggeredGridLayoutDelegate? = nil) {
//        self.columns = columns
//        self.spacing = spacing
//        self.sectionInsets = sectionInsets
//        self.delegate = delegate
//        super.init()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func prepare() {
//        print("--- StaggeredGridLayout.prepare() called ---")
//        guard let collectionView = collectionView else {
//            print("StaggeredGridLayout.prepare(): collectionView is nil.")
//            return
//        }
//
//        let newContentWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right
//        
//        let shouldRecalculate = cache.isEmpty || columnHeights.isEmpty || newContentWidth != currentLayoutContentWidth
//
//        if !shouldRecalculate {
//            print("StaggeredGridLayout.prepare(): Cache valid, content width unchanged (\(newContentWidth)). Skipping full recalculation.")
//            return
//        }
//        
//        print("StaggeredGridLayout.prepare(): Performing full layout recalculation. Old width: \(currentLayoutContentWidth), New width: \(newContentWidth).")
//        cache.removeAll()
//        columnHeights = Array(repeating: sectionInsets.top, count: columns)
//        currentLayoutContentWidth = newContentWidth
//
//        let availableWidthForItems = newContentWidth - (CGFloat(columns - 1) * spacing)
//        let columnWidth = max(0, availableWidthForItems / CGFloat(columns))
//        
//        print("StaggeredGridLayout.prepare(): Calculated columnWidth = \(columnWidth).")
//
//        for item in 0..<collectionView.numberOfItems(inSection: 0) {
//            let indexPath = IndexPath(item: item, section: 0)
//
//            let shortestColumnIndex = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
//            
//            let xOffset = sectionInsets.left + (columnWidth + spacing) * CGFloat(shortestColumnIndex)
//            let yOffset = columnHeights[shortestColumnIndex]
//
//            let itemHeight = delegate?.staggeredGridLayout(self, heightForItemAtIndexPath: indexPath, columnWidth: columnWidth) ?? 0
//
//            let frame = CGRect(x: xOffset, y: yOffset, width: columnWidth, height: itemHeight)
//            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//            attributes.frame = frame
//            cache.append(attributes)
//
//            columnHeights[shortestColumnIndex] = yOffset + itemHeight + spacing
//        }
//        print("--- End StaggeredGridLayout.prepare() ---")
//    }
//
//    override var collectionViewContentSize: CGSize {
//        guard let collectionView = collectionView else { return .zero }
//        
//        let contentWidth = collectionView.bounds.width
//        let contentHeight = (columnHeights.max() ?? 0) + sectionInsets.bottom
//        
//        print("StaggeredGridLayout.collectionViewContentSize: calculated height = \(contentHeight) for width \(contentWidth).")
//        return CGSize(width: contentWidth, height: contentHeight)
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        return cache.filter { $0.frame.intersects(rect) }
//    }
//
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        guard indexPath.item < cache.count else { return nil }
//        return cache[indexPath.item]
//    }
//
//    // THIS IS THE METHOD IN QUESTION: shouldInvalidateLayout(forBoundsChange:)
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        guard let collectionView = collectionView else { return false }
//        
//        let invalidate = newBounds.width != collectionView.bounds.width
//        
//        if invalidate {
//            print("StaggeredGridLayout.shouldInvalidateLayout: Invalidating layout due to width change (\(collectionView.bounds.width) -> \(newBounds.width)).")
//            cache.removeAll()
//            columnHeights.removeAll()
//            currentLayoutContentWidth = 0
//        } else {
//        }
//        return invalidate
//    }
//}
//
//// MARK: - 4. MultiColumnList (SwiftUI UIViewRepresentable)
//
//struct MultiColumnList<Item: Identifiable>: UIViewRepresentable {
//    var items: [Item]
//    var numberOfColumns: Int
//    var viewForItem: (Item, CGFloat) -> AnyView
//    var onItemAppear: ((_ index: Int, _ item: Item) -> Void)?
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIView(context: Context) -> UICollectionView {
//        let layout = StaggeredGridLayout(columns: numberOfColumns, delegate: context.coordinator)
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.register(HostingCollectionViewCell.self, forCellWithReuseIdentifier: "HostingCell")
//        collectionView.dataSource = context.coordinator
//        collectionView.delegate = context.coordinator
//        collectionView.backgroundColor = .clear
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.contentInsetAdjustmentBehavior = .always
//        
//        print("MultiColumnList.makeUIView: Created UICollectionView.")
//        return collectionView
//    }
//
//    func updateUIView(_ uiView: UICollectionView, context: Context) {
//        context.coordinator.parent = self
//        print("MultiColumnList.updateUIView: Called.")
//
//        guard let layout = uiView.collectionViewLayout as? StaggeredGridLayout else {
//            fatalError("CollectionView layout is not StaggeredGridLayout")
//        }
//
//        if layout.columns != numberOfColumns {
//            print("MultiColumnList.updateUIView: Column count changed from \(layout.columns) to \(numberOfColumns).")
//            layout.columns = numberOfColumns
//            context.coordinator.itemHeightCache.removeAll() // Clear height cache if columns change
//        }
//        
//        // This is the core logic to force a re-layout and redraw.
//        // It triggers the sequence: shouldInvalidateLayout -> prepare -> cellForItemAt for visible cells.
//        layout.invalidateLayout()
//        uiView.reloadData()
//        
//        print("MultiColumnList.updateUIView: layout.invalidateLayout() and reloadData() called.")
//    }
//
//    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, StaggeredGridLayoutDelegate {
//        var parent: MultiColumnList
//        var itemHeightCache: [AnyHashable: CGFloat] = [:]
//
//        init(_ parent: MultiColumnList) {
//            self.parent = parent
//            print("Coordinator: Initialized.")
//        }
//
//        // MARK: UICollectionViewDataSource
//
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            let count = parent.items.count
//            print("Coordinator.collectionView(_:numberOfItemsInSection:): Returning \(count) items.")
//            return count
//        }
//
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HostingCell", for: indexPath) as! HostingCollectionViewCell
//            let item = parent.items[indexPath.item]
//
//            guard let layout = collectionView.collectionViewLayout as? StaggeredGridLayout else {
//                fatalError("CollectionView layout is not StaggeredGridLayout")
//            }
//            let availableContentWidth = collectionView.bounds.width - layout.sectionInsets.left - layout.sectionInsets.right
//            let totalSpacingInColumns = layout.spacing * CGFloat(layout.columns - 1)
//            let columnWidth = max(0, (availableContentWidth - totalSpacingInColumns) / CGFloat(layout.columns))
//            
//            print("Coordinator.collectionView(_:cellForItemAt:): Item \(indexPath.item) - Calculated columnWidth for cell: \(columnWidth).")
//
//            let itemSwiftUIView = parent.viewForItem(item, columnWidth)
//                .id(columnWidth) // CRUCIAL: Forces SwiftUI to re-evaluate the view when columnWidth changes
//                .eraseToAnyView()
//
//            cell.host(view: itemSwiftUIView)
//            return cell
//        }
//
//        // MARK: UICollectionViewDelegate
//
//        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//            guard indexPath.item < parent.items.count else { return }
//            let item = parent.items[indexPath.item]
//            print("Coordinator.collectionView(_:willDisplay:): Item \(indexPath.item) will appear.")
//            parent.onItemAppear?(indexPath.item, item)
//        }
//        
//        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//             print("Coordinator.collectionView(_:didEndDisplaying:): Item \(indexPath.item) did disappear.")
//        }
//
//        // MARK: StaggeredGridLayoutDelegate
//
//        func staggeredGridLayout(_ layout: StaggeredGridLayout, heightForItemAtIndexPath indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
//            guard indexPath.item < parent.items.count else {
//                print("Coordinator.staggeredGridLayout: Index path out of bounds for item \(indexPath.item). Returning 0 height.")
//                return 0
//            }
//            let item = parent.items[indexPath.item]
//
//            if let cachedHeight = itemHeightCache[item.id] {
//                print("Coordinator.staggeredGridLayout: Using cached height \(cachedHeight) for item \(indexPath.item) at width \(columnWidth).")
//                return cachedHeight
//            }
//
//            print("Coordinator.staggeredGridLayout: Measuring item \(indexPath.item) for height at columnWidth: \(columnWidth).")
//
//            let dummySwiftUIView = parent.viewForItem(item, columnWidth)
//                .id(columnWidth) // CRUCIAL: Matches the .id() used in cellForItemAt to ensure consistent measurement
//                .eraseToAnyView()
//
//            let dummyHostingController = UIHostingController(rootView: dummySwiftUIView)
//            dummyHostingController.view.translatesAutoresizingMaskIntoConstraints = false
//
//            let targetSize = CGSize(width: columnWidth, height: UIView.layoutFittingExpandedSize.height)
//            let fittingSize = dummyHostingController.view.systemLayoutSizeFitting(
//                targetSize,
//                withHorizontalFittingPriority: .required,
//                verticalFittingPriority: .fittingSizeLevel
//            )
//
//            let calculatedHeight = fittingSize.height
//            print("Coordinator.staggeredGridLayout: Measured height for item \(indexPath.item): \(calculatedHeight) at width: \(columnWidth).")
//
//            itemHeightCache[item.id] = calculatedHeight
//            return calculatedHeight
//        }
//    }
//}
