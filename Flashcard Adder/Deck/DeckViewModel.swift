//
//  DeckViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import Foundation
import os.log

struct DeckViewModel {
    var main: [Deck]
    var defaultDeck: Deck
    var selectedDeck: Deck
    
    var defaultDeckList: [Deck] {
        [defaultDeck]
    }
    
    init(selected: Deck) {
        main = FlashcardSettings.shared.decks
        defaultDeck = FlashcardSettings.shared.defaultDeck
        main.remove(at: main.firstIndex(of: defaultDeck)!)
        self.selectedDeck = selected
    }
    
    mutating func selectDeck(_ deck: Deck) {
        selectedDeck = deck
    }
    
    mutating func addNewDeck(with name: String) {
        let deck = Deck(name: name)
        Logger.deck.info("Deck \(deck.name)")
        // Check for and tell view controller to produce alert if deck type already exists
        if (main.firstIndex(of: deck) == nil) {
            main.append(deck)
            FlashcardSettings.shared.decks.append(deck)
        }
    }
}
