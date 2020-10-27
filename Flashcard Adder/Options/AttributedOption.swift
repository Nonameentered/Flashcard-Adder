//
//  AttributedOption.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

protocol AttributedOption: Hashable {
    associatedtype sourceType: Option
    var source: sourceType { get }
    var isDefault: Bool { get }
    var isSelected: Bool { get }
    var selected: sourceType { get }
    var name: String { get }
    var nameAsNSString: NSString { get }

    init(source: sourceType, selected: sourceType)
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
