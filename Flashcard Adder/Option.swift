//
//  Option.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/25/20.
//

import Foundation

protocol Option {
    var name: String { get }
}
//
protocol AttributedManager {
    associatedtype sourceType
    var selected: sourceType { get set }
}
protocol AttributedOption {
    associatedtype sourceType
    associatedtype managerType
    var source: sourceType { get }
    var isDefault: Bool { get }
    var isSelected: Bool { get }
    var manager: managerType { get }
    var name: String { get }
    var nameAsNSString: NSString { get }
}

extension AttributedOption where sourceType: Option, managerType: AttributedManager, managerType.sourceType: Option {
    
    var name: String {
        source.name
    }

    var nameAsNSString: NSString {
        source.name as NSString
    }
}

protocol ViewModel {
    
}

/*
struct AttributedItem<T: Hashable & Option>: Hashable {
    static func == (lhs: AttributedItem, rhs: AttributedItem) -> Bool {
        lhs.source == rhs.source && lhs.isDefault == rhs.isDefault && lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isSelected)
        hasher.combine(isDefault)
    }
    
    let source: T
//    let delegate: AttributedDelegate
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultDeck
    }
    
    // Maybe should be rewritten into a computed property, with a delegate
    var isSelected: Bool {
        source == delegate.selected
    }
    
    var name: String {
        source.name
    }
    
    var nameAsNSString: NSString {
        source.name as NSString
    }
}
*/
