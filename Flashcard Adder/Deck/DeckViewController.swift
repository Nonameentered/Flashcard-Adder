//
//  DeckViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import os.log
import UIKit

protocol DeckViewControllerDelegate {
    func deckSelected(_ deck: Deck)
}

protocol OptionViewControllerDelegate {
    func profileChanged(_ profile: Profile)
    func deckChanged(_ deck: Deck)
}

/*
class DeckViewController: UIViewController {
    enum Section: CaseIterable {
        case usual
        case main
    }

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: DeckViewModel
    let delegate: DeckViewControllerDelegate
    
    init(viewModel: DeckViewModel, delegate: DeckViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        setUpNavBar()
        configureHierarchy()
        applySnapshot(animatingDifferences: false)
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        Logger.deck.info("DeckViewController loaded")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Logger.deck.info("DeckViewController will disappear")
    }
    
    func setUpNavBar() {
        self.navigationItem.title = "Decks"
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancel))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        self.navigationItem.leftBarButtonItems = [doneButton]
        self.navigationItem.rightBarButtonItems = [addButton]
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func add() {
        showInputDialog(title: "Add Deck", message: "Enter a deck name", cancelHandler: nil) { deckName in
            if let deckName = deckName, !deckName.isEmpty {
                self.viewModel.add(Deck(name: deckName))
            }
        }
    }
    
    func edit(oldDeck: AttributedDeck) {
        showInputDialog(title: "Edit Deck", message: "Enter a modified deck name", actionTitle: "OK", inputPlaceholder: oldDeck.name, cancelHandler: nil) { deckName in
            if let deckName = deckName, !deckName.isEmpty {
                self.viewModel.edit(from: oldDeck, to: Deck(name: deckName))
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
        config.leadingSwipeActionsConfigurationProvider = { [unowned self] indexPath -> UISwipeActionsConfiguration in
            var actions = [UIContextualAction]()
            if let deck = dataSource.itemIdentifier(for: indexPath) {
                if !deck.isDefault {
                    actions.append(UIContextualAction(style: .normal, title: "Set Default") { _, _, completion in
                        self.viewModel.move(deck, to: IndexPath(row: 0, section: 0))

                        completion(true)
                    })
                }
            }
            return UISwipeActionsConfiguration(actions: actions)
        }
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath -> UISwipeActionsConfiguration in
            var actions = [UIContextualAction]()
            if let deck = dataSource.itemIdentifier(for: indexPath) {
                if !deck.isSelected && !deck.isDefault {
                    actions.append(UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                        self.viewModel.delete(deck)
                        self.applySnapshot(animatingDifferences: true)
                        completion(true)
                    })
                }
                actions.append(UIContextualAction(style: .normal, title: "Edit") { _, _, completion in
                    self.edit(oldDeck: deck)
                    completion(true)
                })
            }
            return UISwipeActionsConfiguration(actions: actions)
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
        snapshot.appendItems(viewModel.main, toSection: .main)
        snapshot.appendItems(viewModel.usual, toSection: .usual)

        dataSource.supplementaryViewProvider = { [unowned self] (collectionView: UICollectionView, _: String, indexPath: IndexPath) -> UICollectionReusableView? in
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: FlashcardSettings.ElementKind.sectionHeader, withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier, for: indexPath) as? HeaderSupplementaryView {
                print(self.dataSource.itemIdentifier(for: indexPath))
                headerView.label.text = self.dataSource.itemIdentifier(for: indexPath)?.isDefault ?? false ? "Default" : "Other Decks"
                return headerView
            } else {
                fatalError("Cannot create supplementary header view")
            }
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension DeckViewController: DeckViewModelDelegate {
    func decksDidChange(_ viewModel: DeckViewModel, animatingDifferences: Bool) {
        DispatchQueue.main.async {
            self.applySnapshot(animatingDifferences: animatingDifferences)
        }
        
    }
}

extension DeckViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        collectionView.deselectItem(at: indexPath, animated: true)
        if let deck = dataSource.itemIdentifier(for: indexPath) {
            delegate.deckSelected(deck.source)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension DeckViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if let item = dataSource.itemIdentifier(for: indexPath), !item.isDefault {
            let itemProvider = NSItemProvider(object: item.nameAsNSString)
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
                self.viewModel.move(deck, to: destinationIndexPath)
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
*/
