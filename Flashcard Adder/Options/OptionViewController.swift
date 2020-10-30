//
//  OptionViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/26/20.
//

import os.log
import UIKit

class OptionViewController<ViewModel: OptionViewModel>: UIViewController, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: ViewModel
    
    typealias TypedAttributedOption = ViewModel.AttributedSourceType
    typealias TypedOption = TypedAttributedOption.sourceType
    typealias TypedSession = Section<TypedAttributedOption>
    typealias DataSource = UICollectionViewDiffableDataSource<TypedSession, TypedAttributedOption>

    init(viewModel: ViewModel) {
        self.viewModel = viewModel

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
        Logger.option.info("OptionViewController loaded")
    }

    override func viewWillDisappear(_ animated: Bool) {
        Logger.option.info("OptionViewController will disappear")
    }

    func setUpNavBar() {
        navigationItem.title = TypedOption.typeNamePlural
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancel))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navigationItem.leftBarButtonItems = [doneButton]
        navigationItem.rightBarButtonItems = [addButton]
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func add() {
        switch ViewModel.self {
        case is NoteViewModel.Type:
            present(UINavigationController(rootViewController: NoteViewController()), animated: true, completion: nil)
        default:
            showInputDialog(title: "Add \(TypedOption.typeName)", message: "Enter a \(TypedOption.typeName.lowercased()) name", cancelHandler: nil) { optionName in
                if let optionName = optionName, !optionName.isEmpty {
                    self.viewModel.add(TypedOption(name: optionName))
                }
            }
        }
    }

    func edit(oldOption: TypedAttributedOption) {
        switch oldOption {
        case let oldNote as AttributedNote:
            present(UINavigationController(rootViewController: NoteViewController(note: oldNote)), animated: true, completion: nil)
        default:
            showInputDialog(title: "Edit \(TypedOption.typeName)", message: "Enter a modified \(TypedOption.typeName.lowercased()) name", actionTitle: "OK", inputPlaceholder: oldOption.name, cancelHandler: nil) { optionName in
                if let optionName = optionName, !optionName.isEmpty {
                    self.viewModel.edit(from: oldOption, to: TypedOption(name: optionName))
                }
            }
        }
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        collectionView.deselectItem(at: indexPath, animated: true)
        if let option = dataSource.itemIdentifier(for: indexPath) {
            viewModel.select(option.source)
            dismiss(animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//
//        // Get the view for the first header
//        let indexPath = IndexPath(row: 0, section: section)
//        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//
//        // Use this view to calculate the optimal size based on the collection view's width
//        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
//                                                  withHorizontalFittingPriority: .required, // Width is fixed
//                                                  verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
//    }

    // MARK: UICollectionViewDragDelegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if let item = dataSource.itemIdentifier(for: indexPath), !item.isDefault {
            let itemProvider = NSItemProvider(object: item.nameAsNSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        }
        return []
    }

    // MARK: UICollectionViewDropDelegate

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }

        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else {
                return
            }
            if let option = self.dataSource.itemIdentifier(for: sourceIndexPath) {
                self.viewModel.move(option, to: destinationIndexPath)
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

extension OptionViewController {
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)

        config.headerMode = .supplementary
        config.leadingSwipeActionsConfigurationProvider = { [unowned self] indexPath -> UISwipeActionsConfiguration in
            var actions = [UIContextualAction]()
            if let option = dataSource.itemIdentifier(for: indexPath) {
                if !option.isDefault {
                    actions.append(UIContextualAction(style: .normal, title: "Set Default") { _, _, completion in
                        self.viewModel.makeDefault(option)
                        completion(true)
                    })
                }
            }
            return UISwipeActionsConfiguration(actions: actions)
        }
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath -> UISwipeActionsConfiguration in
            var actions = [UIContextualAction]()
            if let option = dataSource.itemIdentifier(for: indexPath) {
                if !option.isSelected, !option.isDefault {
                    actions.append(UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                        self.viewModel.delete(option)
                        completion(true)
                    })
                }
                actions.append(UIContextualAction(style: .normal, title: "Edit") { _, _, completion in
                    self.edit(oldOption: option)
                    completion(true)
                })
            }
            return UISwipeActionsConfiguration(actions: actions)
        }
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension OptionViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(HeaderSupplementaryView.self, forSupplementaryViewOfKind: FlashcardSettings.ElementKind.sectionHeader, withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier)
    }

    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, TypedAttributedOption> {
        UICollectionView.CellRegistration { cell, _, option in
            var content = cell.defaultContentConfiguration()
            content.text = option.name
            cell.contentConfiguration = content
            cell.accessories = option.isSelected ? [.checkmark()] : []
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<TypedSession, TypedAttributedOption> {
        let dataSource = UICollectionViewDiffableDataSource<TypedSession, TypedAttributedOption>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: TypedAttributedOption) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: self.makeCellRegistration(), for: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: FlashcardSettings.ElementKind.sectionHeader, withReuseIdentifier: HeaderSupplementaryView.reuseIdentifier, for: indexPath) as? HeaderSupplementaryView
            headerView?.label.text = section.title
            return headerView
        }
        return dataSource
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<TypedSession, TypedAttributedOption>()
        snapshot.appendSections(viewModel.sections)
        viewModel.sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension OptionViewController: OptionViewModelDelegate {
    func updateList(animatingDifferences: Bool) {
        DispatchQueue.main.async {
            self.applySnapshot(animatingDifferences: animatingDifferences)
        }
    }
}

extension OptionViewController: NoteViewControllerDelegate {
    func addNote(note: Note) {
        if let note = note as? TypedOption {
            self.viewModel.add(note)
        }
    }
    
    func editNote(old: AttributedNote, new: Note) {
        if let old = old as? TypedAttributedOption, let new = new as? TypedOption {
            self.viewModel.edit(from: old, to: new)
        }
    }
    
    
}
