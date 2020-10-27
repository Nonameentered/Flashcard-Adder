//
//  NoteTypeViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/15/20.
//

import Foundation

// Maybe rewrite to fit with DeckViewModel
struct NoteTypeViewModel {
    var main: [Note]
    var defaultNote: Note
    var defaultClozeNote: Note
    var selectedNote: Note
    
    var defaultNoteList: [Note] {
        [defaultNote]
    }
    
    var defaultClozeNoteList: [Note] {
        [defaultClozeNote]
    }
    
    init(selected: Note) {
        main = FlashcardSettings.shared.noteTypes
        defaultNote = FlashcardSettings.shared.defaultNoteType
        defaultClozeNote = FlashcardSettings.shared.defaultClozeNoteType
        main.remove(at: main.firstIndex(of: defaultNote)!)
        main.remove(at: main.firstIndex(of: defaultClozeNote)!)
        selectedNote = selected
    }
    
    mutating func selectNote(_ note: Note) {
        selectedNote = note
    }
    
    mutating func addNewNote(_ note: Note) {
        // Check for and produce alert if note type already exists
        if main.firstIndex(of: note) == nil {
            main.append(note)
            FlashcardSettings.shared.noteTypes.append(note)
        }
    }
}
