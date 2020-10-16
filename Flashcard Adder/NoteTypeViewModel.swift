//
//  NoteTypeViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/15/20.
//

import Foundation

struct NoteTypeViewModel {
    var main: [Note]
    var selected: [Note]
    var selectedNote: Note
    
    init(selected: Note) {
        main = FlashcardSettings.shared.noteTypes
//        main.remove(at: main.firstIndex(of: selected)!)
        self.selected = [selected]
        self.selectedNote = selected
    }
    
    mutating func selectNote(_ note: Note) {
//        main.append(contentsOf: selected)
//        selected = [note]
//        main.remove(at: main.firstIndex(of: selected[0])!)
        selectedNote = note
    }
    
    mutating func addNewNote(_ note: Note) {
        // Check for and produce alert if note type already exists
        if (main.firstIndex(of: note) == nil) {
            main.append(note)
        }
    }
}
