//
//  DeckViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import Foundation
import os.log

struct AttributedDeck: Hashable, AttributedOption {
    let source: Deck
    let selected: Deck
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultDeck
    }
    
    // Maybe should be rewritten into a computed property, with a delegate
    
}

protocol DeckViewModelDelegate {
    func decksDidChange(_ viewModel: DeckViewModel, animatingDifferences: Bool)
}

struct DeckViewModel {
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
        all = [] // Maybe make the manager a different object?
        all = FlashcardSettings.shared.decks.map { AttributedDeck(source: $0, selected: selected) }
    }
    
    mutating func select(_ deck: AttributedDeck) {
        self.selected = deck.source
    }
    
    mutating func add(_ deck: Deck) {
        let attributedDeck = AttributedDeck(source: deck, selected: selected)
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
            makeDefault(deck)
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
        let newAttributedDeck = AttributedDeck(source: newDeck, selected: selected)
        if all.firstIndex(of: newAttributedDeck) == nil, let replaceIndex = all.firstIndex(of: oldDeck) {
            all[replaceIndex] = newAttributedDeck
        }
        delegate?.decksDidChange(self, animatingDifferences: true)
    }
}
