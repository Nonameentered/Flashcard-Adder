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
}

struct DeckViewModel {
    let original: [Deck]
    let originalDefault: Deck
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
    
//    var defaultDeckList: [Deck] {
//        [defaultDeck]
//    }
    
//    var selectedDeckList: [Deck] {
//        [selectedDeck]
//    }
    
    init(selected: Deck) {
        all = FlashcardSettings.shared.decks.map { AttributedDeck(deck: $0, selected: selected) }
        original = FlashcardSettings.shared.decks
        originalDefault = FlashcardSettings.shared.defaultDeck
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
        if FlashcardSettings.shared.defaultDeck != deck.source {
            if selectedDeck == deck.source {
                selectDeck(FlashcardSettings.shared.defaultDeck)
            }
            all.removeAll { $0.source == deck.source }
            FlashcardSettings.shared.decks = all.map { $0.source }
            print(FlashcardSettings.shared.decks)
        }
    }
    
    mutating func moveDeck(_ deck: AttributedDeck, to indexPath: IndexPath) {
        if indexPath.section == 0 {
            setDefaultDeck(deck)
        }
        if !deck.isDefault, let moved = main.moved(deck, to: indexPath.row) {
            all = usual + moved
            FlashcardSettings.shared.decks = all.map { $0.source } // Maybe put in didSet
        }
    }
    
    mutating func setDefaultDeck(_ deck: AttributedDeck) {
        FlashcardSettings.shared.defaultDeck = deck.source
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
