//
//  DeckViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/17/20.
//

import Foundation
import os.log

protocol DeckViewModelDelegate {
    func defaultDeckNotDeletable()
}

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
}

struct DeckViewModel {
    var all: [AttributedDeck]
    var main: [AttributedDeck] {
        all.filter { !$0.isDefault }
    }
    var usual: [AttributedDeck] {
        all.filter { $0.isDefault }
    }
    var selectedDeck: Deck {
        all.first { $0.isSelected }!.source
    }

    var delegate: DeckViewModelDelegate?
    
//    var defaultDeckList: [Deck] {
//        [defaultDeck]
//    }
    
//    var selectedDeckList: [Deck] {
//        [selectedDeck]
//    }
    
    init(selected: Deck) {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: selected) }
        
//        main = FlashcardSettings.shared.decks
//        defaultDeck = FlashcardSettings.shared.defaultDeck
        ////        main.remove(at: main.firstIndex(of: defaultDeck)!)
//        selectedDeck = selected
//        selectDeck(selected)
    }
    
    /*
     mutating func splitSectionWith() {
         if let index = all.firstIndex(of: selectedDeck) {
         }
     }
     */
    
    mutating func selectAttributedDeck(_ deck: AttributedDeck) {
        selectDeck(deck.source)
    }
    
    private mutating func selectDeck(_ deck: Deck) {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: deck) }
    }
    
    mutating func addNewDeck(_ deck: AttributedDeck) {
        Logger.deck.info("Deck \(deck.name)")
        let source = deck.source
        // Check for and tell view controller to produce alert if deck type already exists
        if FlashcardSettings.shared.decks.firstIndex(of: source) == nil {
            FlashcardSettings.shared.decks.append(source)
            reload()
        }
    }
    
    mutating func reload() {
        let selectedDeck = self.selectedDeck
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: selectedDeck) }
    }
    
    mutating func deleteDeck(_ deck: AttributedDeck) {
        if FlashcardSettings.shared.defaultDeck == deck.source {
            delegate?.defaultDeckNotDeletable()
        } else {
            if selectedDeck == deck.source {
                selectDeck(FlashcardSettings.shared.defaultDeck)
            }
            print(all)
            all.removeAll { $0.source == deck.source }
            print(all)
            FlashcardSettings.shared.decks = all.map { $0.source }
            print(FlashcardSettings.shared.decks)
        }
    }
}
