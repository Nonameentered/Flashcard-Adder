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

    var selected: Deck {
        all.first { $0.isSelected }!.source
    }
    
    init(selected: Deck) {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: selected) }
        original = FlashcardSettings.shared.decks
        originalDefault = FlashcardSettings.shared.defaultDeck
    }
    
    mutating func select(_ deck: AttributedDeck) {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: deck.source) }
    }
    
    mutating func add(_ deck: AttributedDeck) {
        // Check for and tell view controller to produce alert if deck type already exists
        if all.firstIndex(of: deck) == nil {
            all.append(deck)
        }
    }
    
    mutating func delete(_ deck: AttributedDeck) {
        all.removeAll { $0.source == deck.source }
    }
    
    mutating func move(_ deck: AttributedDeck, to indexPath: IndexPath) {
        if indexPath.section == 0 {
            setDefault(deck)
        }
        if !deck.isDefault, let moved = main.moved(deck, to: indexPath.row) {
            all = usual + moved
        }
    }
    
    mutating func setDefault(_ deck: AttributedDeck) {
        FlashcardSettings.shared.defaultDeck = deck.source
    }
    
    mutating func edit(from oldDeck: AttributedDeck, to newDeck: AttributedDeck) {
        if all.firstIndex(of: newDeck) == nil, let replaceIndex = all.firstIndex(of: oldDeck) {
            all[replaceIndex] = newDeck
        }
    }
}
