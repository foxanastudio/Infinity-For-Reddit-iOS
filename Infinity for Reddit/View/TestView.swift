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
        label: "com.foxana.infinity",
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
        
        init(delegate: UICollectionViewDelegate?) {
            self.delegate = delegate
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
        
        //let totalSpacing = (numberOfColumns - 1) * spacing
//        let totalSpacing: CGFloat = 0
//        let availableWidth = collectionView.bounds.width - totalSpacing - collectionView.contentInset.left - collectionView.contentInset.right
//        
//        // Width per cell
//        let numberOfColumns: CGFloat = 3
//        let itemWidth = floor(availableWidth / numberOfColumns)
//        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth) // Square cells
//            flowLayout.minimumInteritemSpacing = 16
//            flowLayout.minimumLineSpacing = 16
//        }
        return collectionView
    }
    
    func updateUIView(_ uiView: UIKitCollectionView,
                      context: Context) {
        uiView.apply(
            snapshot,
            animatingDifferences: animatingDifferences,
            completion: updateCallBack
        )
        
//        let totalSpacing: CGFloat = 0
//        let availableWidth = uiView.bounds.width - totalSpacing - uiView.contentInset.left - uiView.contentInset.right
//        
//        // Width per cell
//        let numberOfColumns: CGFloat = 3
//        let itemWidth = floor(availableWidth / numberOfColumns)
//        if let flowLayout = uiView.collectionViewLayout as? UICollectionViewFlowLayout {
//            print(itemWidth)
//            flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth) // Square cells
//            flowLayout.minimumInteritemSpacing = 0
//            flowLayout.minimumLineSpacing = 0
//        }
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
                collectionViewLayout: createStaggeredLayout,
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
        //Text("\(item * 10000)")
//        SimpleTouchItemRow(text: "Add account", icon: "person.crop.circle.badge.plus") {
//            //onLogin()
//            print("fuck")
//        }
        Text(Utils.randomString(length: item))
    }
}

extension ContentView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let noOfCellsInRow = 2
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        let totalSpace = flowLayout.sectionInset.left
//        + flowLayout.sectionInset.right
//        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
//        
//        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return flowLayout
    }
    
    func createStaggeredLayout() -> UICollectionViewLayout {
        // 1. Define a single item that takes up the full width/height of its column container
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100) // Self-sizing or dynamic height
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 2. Create vertical groups (these act as your columns)
        let columnSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5), // 2 columns (0.5 each)
            heightDimension: .estimated(1000)
        )
        
        // Left column group
        let leftGroup = NSCollectionLayoutGroup.vertical(layoutSize: columnSize, subitems: [item])
        // Right column group
        let rightGroup = NSCollectionLayoutGroup.vertical(layoutSize: columnSize, subitems: [item])
        
        // 3. Combine the columns into a horizontal container group
        let containerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1000)
        )
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: containerSize,
            subitems: [leftGroup, rightGroup]
        )
        containerGroup.interItemSpacing = .fixed(10) // Spacing between columns
        
        // 4. Create the section and layout
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.interGroupSpacing = 10 // Spacing between rows
        
        return UICollectionViewCompositionalLayout(section: section)
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
                //cell.translatesAutoresizingMaskIntoConstraints = false
                //cell.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
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
        
        return cell
    }
}
