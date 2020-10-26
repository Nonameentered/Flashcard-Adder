//
//  Option.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/25/20.
//

import Foundation

protocol Option: Hashable {
    var name: String { get }
}

protocol AttributedOption: Hashable {
    associatedtype sourceType
    var source: sourceType { get }
    var isDefault: Bool { get }
    var isSelected: Bool { get }
    var selected: sourceType { get }
    var name: String { get }
    var nameAsNSString: NSString { get }
}

extension AttributedOption where sourceType: Option {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.source == rhs.source && lhs.isDefault == rhs.isDefault && lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isSelected)
        hasher.combine(isDefault)
    }
    
    var name: String {
        source.name
    }

    var nameAsNSString: NSString {
        source.name as NSString
    }
    
    var isSelected: Bool {
        source == selected
    }
}

protocol OptionViewModelDelegate {
    func updateList(animatingDifferences: Bool)
}

protocol OptionViewModel {
    associatedtype attributedSourceType
    associatedtype sourceType
    var all: [attributedSourceType] { get set }
    var main: [attributedSourceType] { get }
    var usual: [attributedSourceType] { get }
    var selected: sourceType { get set }
    var delegate: OptionViewModelDelegate? { get set }
    
    mutating func select(_ item: attributedSourceType)
    mutating func add(_ item: attributedSourceType)
    mutating func delete(_ item: attributedSourceType)
    mutating func move(_ item: attributedSourceType, to indexPath: IndexPath)
    mutating func makeDefault(_ item: attributedSourceType)
    mutating func edit(from oldItem: attributedSourceType, to newItem: attributedSourceType)
}

extension OptionViewModel where attributedSourceType: AttributedOption, sourceType == attributedSourceType.sourceType, sourceType: Hashable {
    var main: [attributedSourceType] {
        all.filter { !$0.isDefault }
    }

    var usual: [attributedSourceType] {
        all.filter { $0.isDefault }
    }
    
    mutating func select(_ item: attributedSourceType) {
        self.selected = item.source
    }
    
    mutating func add(_ item: attributedSourceType) {
        if all.firstIndex(of: item) == nil {
            all.append(item)
        }
        delegate?.updateList(animatingDifferences: true)
    }
    
    mutating func delete(_ item: attributedSourceType) {
        all.removeAll { $0.source == item.source }
    }
    
    mutating func move(_ item: attributedSourceType, to indexPath: IndexPath) {
        if indexPath.section == 0 {
            makeDefault(item)
        }
        if !item.isDefault, let moved = main.moved(item, to: indexPath.row) {
            all = usual + moved
        }
        delegate?.updateList(animatingDifferences: false)
    }
    
    mutating func edit(from oldItem: attributedSourceType, to newItem: attributedSourceType) {
        if all.firstIndex(of: newItem) == nil, let replaceIndex = all.firstIndex(of: oldItem) {
            all[replaceIndex] = newItem
        }
        delegate?.updateList(animatingDifferences: false)
    }
}
