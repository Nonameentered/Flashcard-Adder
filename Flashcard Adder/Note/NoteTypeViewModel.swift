//
//  NoteTypeViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/15/20.
//

import Foundation

struct NoteTypeViewModel {
    var main: [Note]
    var selectedNote: Note
    
    init(selected: Note) {
        main = FlashcardSettings.shared.noteTypes
        self.selectedNote = selected
    }
    
    mutating func selectNote(_ note: Note) {
        selectedNote = note
    }
    
    mutating func addNewNote(_ note: Note) {
        // Check for and produce alert if note type already exists
        if (main.firstIndex(of: note) == nil) {
            main.append(note)
        }
        FlashcardSettings.shared.noteTypes = main
    }
}
