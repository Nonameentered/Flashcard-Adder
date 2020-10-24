//
//  DeckViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import os.log
import UIKit

class DeckViewController: UIViewController {
    enum Section: CaseIterable {
        case usual
        case main
    }

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: DeckViewModel {
        didSet {
            Logger.deck.info("Updated view model")
            applySnapshot(animatingDifferences: true)
        }
    }

    init?(coder: NSCoder, viewModel: DeckViewModel) {
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
        Logger.deck.info("Loaded DeckViewController")
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addDeck(_ sender: Any) {
        showInputDialog(title: "Add Deck", message: "Enter a deck name", cancelHandler: nil) { deckName in
            if let deckName = deckName {
                self.viewModel.addNewDeck(AttributedDeck(deck: Deck(name: deckName)))
            }
        }
    }
}

extension DeckViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)
        
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath -> UISwipeActionsConfiguration in
            if indexPath.section != 0 {

                let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                    self.viewModel.deleteDeck(self.viewModel.all[indexPath.row])
                    completion(true)
                }
                return UISwipeActionsConfiguration(actions: [action])
            }
            return UISwipeActionsConfiguration()
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension DeckViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }

    private func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, AttributedDeck> {
        UICollectionView.CellRegistration { cell, _, deck in
            var content = cell.defaultContentConfiguration()
            content.text = deck.name
            cell.contentConfiguration = content
            var background = UIBackgroundConfiguration.listGroupedCell()
            background.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)?.lighter(by: 5)
            cell.backgroundConfiguration = background
            cell.accessories = deck.isSelected ? [.checkmark()] : []
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, AttributedDeck> {
        UICollectionViewDiffableDataSource<Section, AttributedDeck>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: AttributedDeck) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: self.makeCellRegistration(), for: indexPath, item: item)
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AttributedDeck>()
        snapshot.appendSections(Section.allCases)
//        snapshot.appendItems(viewModel.selectedDeckList, toSection: .usual)
        snapshot.appendItems(viewModel.all, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension DeckViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        collectionView.deselectItem(at: indexPath, animated: true)
        if let deck = dataSource.itemIdentifier(for: indexPath) {
            viewModel.selectAttributedDeck(deck)
            performSegue(withIdentifier: FlashcardSettings.Segues.unwindToFlashcardFromDeckList, sender: true)
        }
    }
}
