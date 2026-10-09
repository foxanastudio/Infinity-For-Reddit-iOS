//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI
import UIKit

struct TestView: View {
    var body: some View {
        
    }
}

final class CollectionViewWithDataSource<SectionIdentifierType, ItemIdentifierType>: UICollectionView
where

SectionIdentifierType: Hashable & Sendable,
ItemIdentifierType: Hashable & Sendable
{
    typealias DataSource = UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    private let cellProvider: DataSource.CellProvider
    
    private let updateQueue: DispatchQueue = DispatchQueue(
        label: "label",
        qos: .userInteractive
    )
    
    private lazy var collectionDataSource: DataSource = {
        DataSource(
            collectionView: self,
            cellProvider: cellProvider
        )
    }()
    
    init(frame: CGRect,
         collectionViewLayout: UICollectionViewLayout,
         collectionViewConfiguration: ((UICollectionView) -> Void),
         cellProvider: @escaping DataSource.CellProvider,
         supplementaryViewProvider: DataSource.SupplementaryViewProvider?
    ) {
        self.cellProvider = cellProvider
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        collectionViewConfiguration(self)
        
        collectionDataSource.supplementaryViewProvider = supplementaryViewProvider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(_ snapshot: Snapshot,
               animatingDifferences: Bool = true,
               completion: (() -> Void)? = nil
    ) {
        updateQueue.async { [weak self] in
            self?.collectionDataSource.apply(
                snapshot,
                animatingDifferences: animatingDifferences,
                completion: completion
            )
        }
    }
}

extension CollectionView {
    typealias UIKitCollectionView = CollectionViewWithDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias DataSource =  UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    typealias UpdateCompletion = () -> Void
}

struct CollectionView<SectionIdentifierType, ItemIdentifierType> where
SectionIdentifierType: Hashable & Sendable,
ItemIdentifierType: Hashable & Sendable
{
    private let snapshot: Snapshot
    private let configuration: ((UICollectionView) -> Void)
    private let cellProvider: DataSource.CellProvider
    private let supplementaryViewProvider: DataSource.SupplementaryViewProvider?
    
    private let collectionViewLayout: () -> UICollectionViewLayout
    
    private(set) var collectionViewDelegate: (() -> UICollectionViewDelegate)?
    private(set) var animatingDifferences: Bool = true
    private(set) var updateCallBack: UpdateCompletion?
    
    init(snapshot: Snapshot,
         collectionViewLayout: @escaping () -> UICollectionViewLayout,
         configuration: @escaping ((UICollectionView) -> Void) = { _ in },
         cellProvider: @escaping  DataSource.CellProvider,
         supplementaryViewProvider: DataSource.SupplementaryViewProvider? = nil
    ) {
        self.snapshot = snapshot
        self.configuration = configuration
        self.cellProvider = cellProvider
        self.supplementaryViewProvider = supplementaryViewProvider
        self.collectionViewLayout = collectionViewLayout
    }
}

extension CollectionView: UIViewRepresentable {
    final class Coordinator {
        var delegate: UICollectionViewDelegate?
        var pinterestDelegate: PinterestLayoutDataSourceProxy
        
        init(delegate: UICollectionViewDelegate?) {
            self.delegate = delegate
            self.pinterestDelegate = PinterestLayoutDataSourceProxy()
            
            // Configure data rules here or bind them to your view model
            pinterestDelegate.itemHeightProvider = { indexPath in
                // Custom logic derived from item data if needed, e.g. based on image aspect ratio
                return CGFloat(150 + (indexPath.item % 3) * 50)
            }
            pinterestDelegate.adsFrequencyProvider = {
                return 0 // Inject ad frequency rules cleanly
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(delegate: collectionViewDelegate?())
    }
    
    func makeUIView(context: Context) -> UIKitCollectionView {
        let collectionView = UIKitCollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout(),
            collectionViewConfiguration: configuration,
            cellProvider: cellProvider,
            supplementaryViewProvider: supplementaryViewProvider
        )
        collectionView.delegate = context.coordinator.delegate
        
        if let layout = collectionView.collectionViewLayout as? PinterestLayout {
            layout.delegate = context.coordinator.pinterestDelegate
        }
        return collectionView
    }
    
    func updateUIView(_ uiView: UIKitCollectionView,
                      context: Context) {
        uiView.apply(
            snapshot,
            animatingDifferences: animatingDifferences,
            completion: updateCallBack
        )
    }
}

extension CollectionView {
    func animateDifferences(_ animate: Bool) -> Self {
        var selfCopy = self
        selfCopy.animatingDifferences = animate
        return selfCopy
    }
    
    func onUpdate(_ perform: (() -> Void)?) -> Self {
        var selfCopy = self
        selfCopy.updateCallBack = perform
        return selfCopy
    }
    
    func collectionViewDelegate(_ makeDelegate: @escaping (() -> UICollectionViewDelegate)) -> Self {
        var selfCopy = self
        selfCopy.collectionViewDelegate = makeDelegate
        return selfCopy
    }
}

final class CollectionViewDelegateProxy: NSObject, UICollectionViewDelegate {
    let didScroll: (UIScrollView) -> Void
    let didSelect: (UICollectionView, IndexPath) -> Void
    
    init(didScroll: @escaping (UIScrollView) -> Void,
         didSelect: @escaping (UICollectionView, IndexPath) -> Void) {
        
        self.didScroll = didScroll
        self.didSelect = didSelect
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect(collectionView, indexPath)
    }
}

struct ContentView: View {
    typealias Item = Int
    typealias Section = Int
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    @State var snapshot: Snapshot = {
        var initialSnapshot = Snapshot()
        initialSnapshot.appendSections([0])
        return initialSnapshot
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            CollectionView(
                snapshot: snapshot,
                collectionViewLayout: collectionViewLayout,
                cellProvider: cellProviderWithRegistration
            )
            
            Button(
                action: {
                    let itemsCount = snapshot.numberOfItems(inSection: 0)
                    snapshot.appendItems([itemsCount + 1], toSection: 0)
                }, label: {
                    Text("Add More Items")
                }
            )
        }
    }
    
    let cellRegistration: UICollectionView.CellRegistration = .hosting { (idx: IndexPath, item: Item) in
        Text(Utils.randomString(length: item))
    }
}

extension ContentView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let pinterestLayout = PinterestLayout()
        return pinterestLayout
    }
    
    func collectionViewConfiguration(_ collectionView: UICollectionView) {
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "CellReuseId"
        )
        
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: "KindOfHeader",
            withReuseIdentifier: "SupplementaryReuseId"
        )
    }
    
    func cellProvider(
        _ collectionView: UICollectionView,
        indexPath: IndexPath,
        item: Item
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CellReuseId",
            for: indexPath
        )
        
        cell.backgroundColor = .red
        return cell
    }
    
    func supplementaryProvider(_ collectionView: UICollectionView,
                               elementKind: String,
                               indexPath: IndexPath) -> UICollectionReusableView {
        collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKind,
            withReuseIdentifier: "SupplementaryReuseId",
            for: indexPath
        )
    }
}

extension UICollectionView.CellRegistration {
    static func hosting<Content: View, Item>(
        content: @escaping (IndexPath, Item) -> Content
    ) -> UICollectionView.CellRegistration<UICollectionViewCell, Item> {
            UICollectionView.CellRegistration { cell, indexPath, item in
                cell.contentConfiguration = UIHostingConfiguration {
                    content(indexPath, item)
                }
            }
        }
}

extension ContentView {
    func cellProviderWithRegistration(_ collectionView: UICollectionView,
                                      indexPath: IndexPath,
                                      item: Item) -> UICollectionViewCell {
        let cell = collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
        
        cell.backgroundColor = .blue
        
        return cell
    }
}




final class PinterestLayoutDataSourceProxy: PinterestLayoutDelegate {
    // Optional closure or reference to fetch your model items dynamically
    var itemHeightProvider: ((IndexPath) -> CGFloat)?
    var bannerHeightProvider: ((IndexPath) -> CGFloat)?
    var adsFrequencyProvider: (() -> Int)?

    func collectionView(
        _ collectionView: UICollectionView,
        layout: PinterestLayout,
        heightForItemAtIndexPath indexPath: IndexPath
    ) -> CGFloat {
        return itemHeightProvider?(indexPath) ?? 180
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout: PinterestLayout,
        heightForBannerAtIndexPath indexPath: IndexPath
    ) -> CGFloat {
        return bannerHeightProvider?(indexPath) ?? 220
    }

    func numberOfItemsBeforeAds(
        in collectionView: UICollectionView
    ) -> Int {
        return adsFrequencyProvider?() ?? 5 // e.g., show banner every 5 items
    }
}

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForBannerAtIndexPath indexPath: IndexPath) -> CGFloat
    func numberOfItemsBeforeAds(in collectionView: UICollectionView) -> Int
}

extension PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForBannerAtIndexPath indexPath: IndexPath) -> CGFloat { return 0 }
    func numberOfItemsBeforeAds(in collectionView: UICollectionView) -> Int { return Int.max }
}

class PinterestLayout: UICollectionViewLayout {
    static let elementKindBanner: String = "PinterestLayoutElementKindBanner"
    typealias AttributeCache = [UICollectionViewLayoutAttributes]
    
    weak var delegate: PinterestLayoutDelegate?

    private var itemCache: AttributeCache = []
    private var supplementaryCache: [String: AttributeCache] = [:]
    
    private lazy var contentBounds: CGRect = {
        guard let collectionView = collectionView else { return .zero }
        let size = collectionView.bounds.inset(by: collectionView.contentInset).size
        return CGRect(origin: .zero, size: size)
    }()
    
    private var adFrequency: Int {
        guard let collectionView = collectionView,
              let count = delegate?.numberOfItemsBeforeAds(in: collectionView) else { return Int.max }
        return count
    }
    
    var cellPadding: CGFloat = 6 {
        didSet { if oldValue != cellPadding { invalidateLayout() } }
    }
    
    var numberOfColumns = 2 {
        didSet { if oldValue != numberOfColumns { invalidateLayout() } }
    }
    
    var cellWidth: CGFloat {
        return (contentBounds.width / CGFloat(numberOfColumns)) - (cellPadding * 2)
    }
    
    override func prepare() {
        guard let collectionView = collectionView, collectionView.numberOfSections > 0 else { return }

        itemCache.removeAll()
        supplementaryCache.removeAll()
         
        var xOffsets: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        xOffsets = xOffsets.indices.map { CGFloat($0) * contentBounds.width / CGFloat(numberOfColumns) }
         
        var yOffsets: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        let count = collectionView.numberOfItems(inSection: 0)
         
        var column = 0
        var itemIndex = 0
        var adIndex = 0
        let frequency = adFrequency
         
        while itemIndex < count {
            let indexPath = IndexPath(item: itemIndex, section: 0)
             
            let photoHeight = delegate?.collectionView(collectionView, layout: self, heightForItemAtIndexPath: indexPath) ?? 180
            let height = (cellPadding * 2) + photoHeight
            let width = contentBounds.width / CGFloat(numberOfColumns)
            let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: width, height: height)
             
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            itemCache.append(attributes)
            contentBounds = contentBounds.union(frame)
            yOffsets[column] = frame.maxY
            column = yOffsets.indexOfMin ?? 0
            itemIndex += 1
             
            if frequency > 0, itemIndex % frequency == 0 {
                let bannerIndexPath = IndexPath(item: adIndex, section: 0)
                let bannerHeight = delegate?.collectionView(collectionView, layout: self, heightForBannerAtIndexPath: bannerIndexPath) ?? 200
                let bannerFrame = CGRect(x: 0, y: yOffsets.max() ?? 0, width: contentBounds.width, height: bannerHeight)
                 
                let bannerInsetFrame = bannerFrame.insetBy(dx: cellPadding, dy: cellPadding)
                let bannerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Self.elementKindBanner, with: bannerIndexPath)
                bannerAttributes.frame = bannerInsetFrame
                supplementaryCache.updateCollection(keyedBy: PinterestLayout.elementKindBanner, with: bannerAttributes)
                contentBounds = contentBounds.union(bannerFrame)
                yOffsets = yOffsets.map { _ in bannerFrame.maxY }
                adIndex += 1
            }
        }
    }
    
    override var collectionViewContentSize: CGSize { contentBounds.size }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemCache[safe: indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return supplementaryCache[elementKind]?[safe: indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        result.append(contentsOf: binSearchAttributes(in: itemCache, intersecting: rect))
        supplementaryCache.keys.forEach { key in
            if let cache = supplementaryCache[key] {
                result.append(contentsOf: binSearchAttributes(in: cache, intersecting: rect))
            }
        }
        return result
    }
    
    func binSearchAttributes(in cache: AttributeCache, intersecting rect: CGRect) -> AttributeCache {
        var result = [UICollectionViewLayoutAttributes]()
        let start = cache.startIndex
        guard let end = cache.indices.last,
              let firstMatchIndex = findPivot(in: cache, for: rect, start: start, end: end) else { return result }
         
        for attributes in cache[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            result.append(attributes)
        }
        for attributes in cache[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            result.append(attributes)
        }
        return result
    }
    
    func findPivot(in cache: AttributeCache, for rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        let mid = (start + end) / 2
        let attr = cache[mid]
        if attr.frame.intersects(rect) {
            return mid
        } else if attr.frame.maxY < rect.minY {
            return findPivot(in: cache, for: rect, start: (mid + 1), end: end)
        } else {
            return findPivot(in: cache, for: rect, start: start, end: (mid - 1))
        }
    }
}

// MARK: - Helpers Extensions
extension Dictionary where Value: RangeReplaceableCollection {
    mutating func updateCollection(keyedBy key: Key, with element: Value.Element) {
        var collection = self[key] ?? Value()
        collection.append(element)
        self[key] = collection
    }
}

extension Array where Element: Comparable {
    var indexOfMin: Int? {
        guard let min = self.min() else { return nil }
        return self.firstIndex(of: min)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
