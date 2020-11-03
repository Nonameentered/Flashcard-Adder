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
    var isSelected: Bool {
        // ~= is to account for how text can be different in selected note
        return source ~= selected
    }
    var isDefault: Bool {
        isDefaultCloze || isDefaultNormal
    }
    var isDefaultCloze: Bool {
        source == FlashcardSettings.shared.defaultClozeNoteType
    }
    var isDefaultNormal: Bool {
        source == FlashcardSettings.shared.defaultNoteType
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
       return lhs.source == rhs.source && lhs.isDefault == rhs.isDefault && lhs.isSelected == rhs.isSelected && lhs.isDefaultCloze == rhs.isDefaultCloze && lhs.isDefaultNormal == rhs.isDefaultNormal
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isSelected)
        hasher.combine(isDefault)
        hasher.combine(isDefaultNormal)
        hasher.combine(isDefaultCloze)
    }
}
