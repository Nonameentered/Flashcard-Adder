//
//  AttributedNote.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

struct AttributedNote: AttributedOption {
    let source: Note
    let selected: Note
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultNoteType
    }
    var isDefaultCloze: Bool {
        source == FlashcardSettings.shared.defaultClozeNoteType
    }
}
