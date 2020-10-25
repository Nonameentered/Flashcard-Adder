//
//  DeckViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import Foundation
import os.log

struct AttributedDeck: Hashable {
    let source: Deck
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultDeck
    }
    
    // Maybe should be rewritten into a computed property, with a delegate
    var isSelected: Bool = false
    
    var name: String {
        source.name
    }
    
    init(deck: Deck) {
        source = deck
        isSelected = isDefault
    }
    
    init(deck: Deck, selected: Deck) {
        source = deck
        isSelected = deck == selected
    }
    
    init(deck: Deck, isSelected: Bool) {
        source = deck
        self.isSelected = isSelected
    }
}

struct DeckViewModel {
    let original: [Deck]
    let originalDefault: Deck
    var all: [AttributedDeck] {
        didSet {
            FlashcardSettings.shared.decks = all.map { $0.source }
        }
    }
    var main: [AttributedDeck] {
        all.filter { !$0.isDefault }
    }

    var usual: [AttributedDeck] {
        all.filter { $0.isDefault }
    }

    var selectedDeck: Deck {
        all.first { $0.isSelected }!.source
    }
    
    init(selected: Deck) {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: selected) }
        original = FlashcardSettings.shared.decks
        originalDefault = FlashcardSettings.shared.defaultDeck
    }
    
    mutating func selectAttributedDeck(_ deck: AttributedDeck) {
        selectDeck(deck.source)
    }
    
    private mutating func selectDeck(_ deck: Deck) {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: deck) }
    }
    
    mutating func addNewDeck(_ deck: AttributedDeck) {
        // Check for and tell view controller to produce alert if deck type already exists
        if all.firstIndex(of: deck) == nil {
            all.append(deck)
        }
    }
    
    mutating func deleteDeck(_ deck: AttributedDeck) {
        if FlashcardSettings.shared.defaultDeck != deck.source {
            if selectedDeck == deck.source {
                selectDeck(FlashcardSettings.shared.defaultDeck)
            }
            all.removeAll { $0.source == deck.source }
        }
    }
    
    mutating func moveDeck(_ deck: AttributedDeck, to indexPath: IndexPath) {
        if indexPath.section == 0 {
            setDefaultDeck(deck)
        }
        if !deck.isDefault, let moved = main.moved(deck, to: indexPath.row) {
            all = usual + moved
        }
    }
    
    mutating func setDefaultDeck(_ deck: AttributedDeck) {
        FlashcardSettings.shared.defaultDeck = deck.source
    }
    
    mutating func edit(from oldDeck: AttributedDeck, to newDeck: AttributedDeck) {
        if all.firstIndex(of: newDeck) == nil, let replaceIndex = all.firstIndex(of: oldDeck) {
            all[replaceIndex] = newDeck
        }
    }
}

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
