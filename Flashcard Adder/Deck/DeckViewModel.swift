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

struct DeckViewModel: OptionViewModel {
    var all: [AttributedDeck] {
        didSet {
            FlashcardSettings.shared.decks = all.map { $0.source }
        }
    }
    
    var selected: Deck
    var delegate: OptionViewModelDelegate?
    var controllerDelegate: OptionViewControllerDelegate
    
    
    init(selected: Deck, controllerDelegate: OptionViewControllerDelegate) {
        self.selected = selected
        self.controllerDelegate = controllerDelegate
        all = [] // Maybe make the manager a different object?
        generateAll()
    }
    
    mutating func generateAll() {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(source: $0, selected: selected) }
        controllerDelegate.deckChanged(selected)
    }
    
    
    
    mutating func makeDefault(_ item: AttributedDeck) {
        FlashcardSettings.shared.defaultDeck = item.source
        delegate?.updateList(animatingDifferences: false)
    }
}
