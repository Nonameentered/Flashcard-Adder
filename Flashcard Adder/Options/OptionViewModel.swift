//
//  OptionViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

protocol OptionViewModel {
    associatedtype attributedSourceType: AttributedOption
    var all: [attributedSourceType] { get set }
    var main: [attributedSourceType] { get }
    var usual: [attributedSourceType] { get }
    var selected: attributedSourceType.sourceType { get set }
    var delegate: OptionViewModelDelegate? { get set }
    var controllerDelegate: OptionViewControllerDelegate { get set }
    
    init(selected: attributedSourceType.sourceType, controllerDelegate: OptionViewControllerDelegate)
    
    mutating func generateAll()
    mutating func makeDefault(_ item: attributedSourceType)
    
    mutating func select(_ item: attributedSourceType.sourceType) // calls controllerDelegate when called
    mutating func add(_ item: attributedSourceType.sourceType)
    mutating func delete(_ item: attributedSourceType)
    mutating func move(_ item: attributedSourceType, to indexPath: IndexPath)
    mutating func edit(from oldItem: attributedSourceType, to newItem: attributedSourceType.sourceType)
}

extension OptionViewModel where attributedSourceType: AttributedOption, attributedSourceType.sourceType: Option {
    var main: [attributedSourceType] {
        all.filter { !$0.isDefault }
    }

    var usual: [attributedSourceType] {
        all.filter { $0.isDefault }
    }
    
    mutating func select(_ item: attributedSourceType.sourceType) {
        selected = item
        generateAll()
    }
    
    mutating func add(_ item: attributedSourceType.sourceType) {
        let attributedItem = attributedSourceType(source: item, selected: selected)
        if all.firstIndex(of: attributedItem) == nil {
            all.append(attributedItem)
        }
        delegate?.updateList(animatingDifferences: true)
    }
    
    mutating func delete(_ item: attributedSourceType) {
        all.removeAll { $0.source == item.source }
    }
    
    mutating func move(_ item: attributedSourceType, to indexPath: IndexPath) {
        if indexPath.section == 0 {
            makeDefault(item)
        } else {
            if !item.isDefault, let moved = main.moved(item, to: indexPath.row) {
                all = usual + moved
            }
            delegate?.updateList(animatingDifferences: false)
        }
    }
    
    mutating func edit(from oldItem: attributedSourceType, to newItem: attributedSourceType.sourceType) {
        let newAttributedItem = attributedSourceType(source: newItem, selected: selected)
        if all.firstIndex(of: newAttributedItem) == nil, let replaceIndex = all.firstIndex(of: oldItem) {
            all[replaceIndex] = newAttributedItem
            
            if oldItem.isSelected {
                select(newItem)
            }
            if oldItem.isDefault {
                makeDefault(newAttributedItem)
            }
        }
        delegate?.updateList(animatingDifferences: false)
    }
}
