//
//  DeckViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import Foundation
import os.log

struct AttributedDeck: Hashable, AttributedOption {
    static func == (lhs: AttributedDeck, rhs: AttributedDeck) -> Bool {
        lhs.source == rhs.source && lhs.isDefault == rhs.isDefault && lhs.isSelected == rhs.isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isSelected)
        hasher.combine(isDefault)
    }
    
    let source: Deck
    let manager: DeckViewModel
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultDeck
    }
    
    // Maybe should be rewritten into a computed property, with a delegate
    var isSelected: Bool {
        source == manager.selected
    }
}

protocol DeckViewModelDelegate {
    func decksDidChange(_ viewModel: DeckViewModel, animatingDifferences: Bool)
}

struct DeckViewModel: AttributedManager {
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
    
    var selected: Deck
    var delegate: DeckViewModelDelegate?
    
    
    init(selected: Deck) {
        self.selected = selected
        all = [] // Maybe make the delegate a different object?
        all = FlashcardSettings.shared.decks.map { AttributedDeck(source: $0, manager: self) }
    }
    
    mutating func select(_ deck: AttributedDeck) {
        self.selected = deck.source
    }
    
    mutating func add(_ deck: Deck) {
        let attributedDeck = AttributedDeck(source: deck, manager: self)
        // Maybe check for and tell view controller to produce alert if deck type already exists
        if all.firstIndex(of: attributedDeck) == nil {
            all.append(attributedDeck)
        }
        delegate?.decksDidChange(self, animatingDifferences: true)
    }
    
    mutating func delete(_ deck: AttributedDeck) {
        all.removeAll { $0.source == deck.source }
    }
    
    mutating func move(_ deck: AttributedDeck, to indexPath: IndexPath) {
        if indexPath.section == 0 {
            FlashcardSettings.shared.defaultDeck = deck.source
        }
        if !deck.isDefault, let moved = main.moved(deck, to: indexPath.row) {
            all = usual + moved
        }
        delegate?.decksDidChange(self, animatingDifferences: false)
    }
    
    mutating func makeDefault(_ deck: AttributedDeck) {
        FlashcardSettings.shared.defaultDeck = deck.source
    }
    
    mutating func edit(from oldDeck: AttributedDeck, to newDeck: Deck) {
        let newAttributedDeck = AttributedDeck(source: newDeck, manager: self)
        if all.firstIndex(of: newAttributedDeck) == nil, let replaceIndex = all.firstIndex(of: oldDeck) {
            all[replaceIndex] = newAttributedDeck
        }
        delegate?.decksDidChange(self, animatingDifferences: true)
    }
}
