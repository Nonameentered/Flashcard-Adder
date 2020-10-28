//
//  NoteTypeViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/12/20.
//

import os.log
import UIKit

class NoteTypeViewController: UIViewController {
    enum Section: CaseIterable {
        case defaultNote
        case defaultCloze
        case main
    }

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: NoteTypeViewModel {
        didSet {
            Logger.note.info("Updated view model")
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

    @IBAction func unwindToSelectNote(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? OldAddNoteViewController {
            if let note = sourceViewController.note {
                viewModel.addNewNote(note)
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension NoteTypeViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)

        config.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension NoteTypeViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)
        view.addSubview(collectionView)
        view.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)
        collectionView.delegate = self
    }

    private func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Note> {
        UICollectionView.CellRegistration { cell, _, note in
            var content = cell.defaultContentConfiguration()
            content.text = note.name
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listGroupedCell()
            background.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)?.lighter(by: 5)
            cell.backgroundConfiguration = background
            cell.accessories = note ~= self.viewModel.selectedNote ? [.checkmark()] : [] // Will not update because nothing changes in equatable
            // It's possible the better way to do this is have a `selected` value in Note
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
        snapshot.appendItems(viewModel.defaultNoteList, toSection: .defaultNote)
        snapshot.appendItems(viewModel.defaultClozeNoteList, toSection: .defaultCloze)
        snapshot.appendItems(viewModel.main, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension NoteTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        collectionView.deselectItem(at: indexPath, animated: true)
        if let note = dataSource.itemIdentifier(for: indexPath) {
            viewModel.selectNote(note)
            performSegue(withIdentifier: FlashcardSettings.Segues.unwindToFlashcardFromNoteList, sender: true)
        }
    }
}
