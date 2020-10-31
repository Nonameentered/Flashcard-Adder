//
//  OptionViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

protocol OptionViewModel {
    associatedtype AttributedSourceType: AttributedOption
    var all: [AttributedSourceType] { get set }
    var sections: [Section<AttributedSourceType>] { get }
    var main: [AttributedSourceType] { get }
    var usual: [AttributedSourceType] { get }
    var selected: AttributedSourceType.sourceType { get set }
    var delegate: OptionViewModelDelegate? { get set }
    var controllerDelegate: OptionViewControllerDelegate { get }
    
    
    init(selected: AttributedSourceType.sourceType, controllerDelegate: OptionViewControllerDelegate)
    
    mutating func generateAll()
    mutating func makeDefault(_ item: AttributedSourceType)
//    func showAdd()
//    func showEdit(_ current: AttributedSourceType)
    
    mutating func select(_ item: AttributedSourceType.sourceType) // calls controllerDelegate when called
    mutating func add(_ item: AttributedSourceType.sourceType)
    mutating func delete(_ item: AttributedSourceType)
    mutating func move(_ item: AttributedSourceType, to indexPath: IndexPath)
    mutating func edit(from oldItem: AttributedSourceType, to newItem: AttributedSourceType.sourceType)
    
}

extension OptionViewModel where AttributedSourceType: AttributedOption, AttributedSourceType.sourceType: Option {
    
    var sections: [Section<AttributedSourceType>] {
        [Section(title: "Default \(AttributedSourceType.sourceType.typeNamePlural)", items: usual), Section(title: "Other \(AttributedSourceType.sourceType.typeNamePlural)", items: main)]
    }
    var main: [AttributedSourceType] {
        all.filter { !$0.isDefault }
    }

    var usual: [AttributedSourceType] {
        all.filter { $0.isDefault }
    }
    
    mutating func select(_ item: AttributedSourceType.sourceType) {
        selected = item
        generateAll()
    }
    
    mutating func add(_ item: AttributedSourceType.sourceType) {
        let attributedItem = AttributedSourceType(source: item, selected: selected)
        if all.firstIndex(of: attributedItem) == nil {
            all.append(attributedItem)
        }
        delegate?.updateList(animatingDifferences: true)
    }
    
    mutating func delete(_ item: AttributedSourceType) {
        all.removeAll { $0.source == item.source }
        delegate?.updateList(animatingDifferences: true)
    }
    
    mutating func move(_ item: AttributedSourceType, to indexPath: IndexPath) {
        if indexPath.section == 0 {
            makeDefault(item)
        } else {
            if !item.isDefault, let moved = main.moved(item, to: indexPath.row) {
                all = usual + moved
            }
            delegate?.updateList(animatingDifferences: true)
        }
    }
    
    mutating func edit(from oldItem: AttributedSourceType, to newItem: AttributedSourceType.sourceType) {
        print(oldItem)
        print(newItem)
        let newAttributedItem = AttributedSourceType(source: newItem, selected: selected)
        if all.firstIndex(of: newAttributedItem) == nil, let replaceIndex = all.firstIndex(of: oldItem) {
            all[replaceIndex] = newAttributedItem
            
            if oldItem.isSelected {
                select(newItem)
            }
            if oldItem.isDefault {
                makeDefault(newAttributedItem)
            }
        }
        delegate?.updateList(animatingDifferences: true)
    }
}
