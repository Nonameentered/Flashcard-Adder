//
//  DeckViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import os.log
import UIKit

class DeckViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    enum Section: CaseIterable {
        case usual
        case main
    }

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: DeckViewModel

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
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        Logger.deck.info("Loaded DeckViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("GOING To disappaer")
    }

    @IBAction func cancel(_ sender: Any) {
        FlashcardSettings.shared.decks = viewModel.original
        FlashcardSettings.shared.defaultDeck = viewModel.originalDefault
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addDeck(_ sender: Any) {
        showInputDialog(title: "Add Deck", message: "Enter a deck name", cancelHandler: nil) { deckName in
            if let deckName = deckName {
                self.viewModel.addNewDeck(AttributedDeck(deck: Deck(name: deckName)))
                self.applySnapshot(animatingDifferences: true)
            }
        }
    }
}

extension DeckViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)

        config.headerMode = .supplementary
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath -> UISwipeActionsConfiguration in
            if let deck = dataSource.itemIdentifier(for: indexPath), !deck.isSelected && !deck.isDefault {
                let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                    self.viewModel.deleteDeck(deck)
                    self.applySnapshot(animatingDifferences: true)

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
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: FlashcardSettings.ElementKind.sectionHeader, withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier)
    }

    private func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, AttributedDeck> {
        UICollectionView.CellRegistration { cell, _, deck in
            var content = cell.defaultContentConfiguration()
            content.text = deck.name
            cell.contentConfiguration = content
            // without also setting selectedBackgroundView, this disables automatic highlight for selections
            /*
             var background = UIBackgroundConfiguration.listGroupedCell()
             background.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)?.lighter(by: 5)
             cell.backgroundConfiguration = background
             */
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
        snapshot.appendItems(viewModel.usual, toSection: .usual)
        snapshot.appendItems(viewModel.main, toSection: .main)

        dataSource.supplementaryViewProvider = { [unowned self] (collectionView: UICollectionView, _: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: FlashcardSettings.ElementKind.sectionHeader, withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier, for: indexPath) as? HeaderSupplementaryView {
                headerView.label.text = self.dataSource.itemIdentifier(for: indexPath)?.isDefault ?? false ? "Default" : "Other Decks"
                return headerView
            } else {
                fatalError("Cannot create supplementary header view")
            }
        }
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

extension DeckViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            let itemProvider = NSItemProvider(object: item.source.name as NSString) // if this works, add as computed property to AttributedDeck
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        }
        return []
    }
}

extension DeckViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }

        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else {
                return
            }
            if let deck = self.dataSource.itemIdentifier(for: sourceIndexPath) {
                self.viewModel.moveDeck(deck, to: destinationIndexPath)
                applySnapshot(animatingDifferences: false)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
}
