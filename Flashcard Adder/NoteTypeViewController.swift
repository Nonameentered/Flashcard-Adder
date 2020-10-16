//
//  NoteTypeViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/12/20.
//

import UIKit
import os.log

class NoteTypeViewController: UIViewController {
    enum Section: CaseIterable {
        case selected
        case main
    }

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: NoteTypeViewModel {
        didSet {
            applySnapshot(animatingDifferences: true)
        }
    }

    init?(coder: NSCoder, viewModel: NoteTypeViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        applySnapshot(animatingDifferences: false)
        Logger.note.info("Loaded NoteTypeViewController")
    }
}

extension NoteTypeViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension NoteTypeViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }

    private func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Note> {
        UICollectionView.CellRegistration { cell, indexPath, note in
            var content = cell.defaultContentConfiguration()
//            content.text = note ~= self.viewModel.selected ? "selected" : note.name
            content.text = note.name
            
            cell.contentConfiguration = content
//            Logger.note.info("Current note \(note.name)")
//            Logger.note.info("Selected note \(self.viewModel.selected.name)")
//            Logger.note.info("Comparison \(note ~= self.viewModel.selected)")
            
//            cell.accessories = note ~= self.viewModel.selected[0] ? [.checkmark()] : []
//            cell.accessories = note ~= self.viewModel.selected ? [.checkmark()] : []
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Note> {
        UICollectionViewDiffableDataSource<Section, Note>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Note) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: self.makeCellRegistration(), for: indexPath, item: item)
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.selected, toSection: .selected)
        snapshot.appendItems(viewModel.main, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension NoteTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let note = dataSource.itemIdentifier(for: indexPath) {
            viewModel.selectNote(note)
            applySnapshot(animatingDifferences: true)
//            var currentSnapshot = dataSource.snapshot()
//            currentSnapshot.reloadItems([note])
//            dataSource.apply(currentSnapshot)
        }
    }
}
