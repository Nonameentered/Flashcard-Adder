//
//  AttributedDeck.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

struct AttributedDeck: AttributedOption {
    let source: Deck
    let selected: Deck
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultDeck
    }
}
