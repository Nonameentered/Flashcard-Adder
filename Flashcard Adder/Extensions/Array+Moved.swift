//
//  Array+Moved.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/25/20.
//

import Foundation

extension Array where Element: Equatable {
    func moved(_ element: Element, to newIndex: Index) -> Array? where Element: Equatable {
        if let oldIndex: Int = firstIndex(of: element) { return moved(from: oldIndex, to: newIndex) }
        return nil
    }
}

extension Array {
    func moved(from oldIndex: Index, to newIndex: Index) -> Array {
        var newArray = self
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        if oldIndex == newIndex {
        } else if abs(newIndex - oldIndex) == 1 {
            newArray.swapAt(oldIndex, newIndex)
        } else {
            newArray.insert(newArray.remove(at: oldIndex), at: newIndex)
        }
        return newArray
    }
}
