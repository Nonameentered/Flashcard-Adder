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
        case main
    }

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: NoteTypeViewModel

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
        print("LOADED")
        configureHierarchy()
        Logger.note.info("Loaded")
        updateList()
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
        UICollectionView.CellRegistration { cell, _, note in
            var content = cell.defaultContentConfiguration()
            content.text = note.name
            cell.contentConfiguration = content
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Note> {
        UICollectionViewDiffableDataSource<Section, Note>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Note) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: self.makeCellRegistration(), for: indexPath, item: item)
        }
    }

    private func updateList() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.main, toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension NoteTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
