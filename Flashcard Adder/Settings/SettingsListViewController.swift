//
//  SettingsViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/18/20.
//

import UIKit
import os.log

class SettingsListViewController: UIViewController {
    enum Section: CaseIterable {
        case selected
        case main
    }

    lazy var dataSource = makeDataSource()
    var collectionView: UICollectionView!
    var viewModel: SettingsViewModel = SettingsViewModel.shared {
        didSet {
            Logger.settings.info("Updated view model")
            applySnapshot(animatingDifferences: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        applySnapshot(animatingDifferences: false)
        Logger.settings.info("Loaded SettingsViewController")
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsListViewController {
    /// - Tag: List
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension SettingsListViewController {
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }

    private func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Setting> {
        UICollectionView.CellRegistration { cell, _, settings in
            var content = cell.defaultContentConfiguration()
            content.text = settings.name.rawValue
            cell.contentConfiguration = content
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Setting> {
        UICollectionViewDiffableDataSource<Section, Setting>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Setting) -> UICollectionViewCell? in
            collectionView.dequeueConfiguredReusableCell(using: self.makeCellRegistration(), for: indexPath, item: item)
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Setting>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(viewModel.flashcardOptions, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension SettingsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        collectionView.deselectItem(at: indexPath, animated: true)
        if let settings = dataSource.itemIdentifier(for: indexPath) {
            viewModel.selected(setting: settings)
        }
    }
}
