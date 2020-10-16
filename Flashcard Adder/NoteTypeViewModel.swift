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
    
    init(selected: Note) {
        main = FlashcardSettings.shared.noteTypes
        main.remove(at: main.firstIndex(of: selected)!)
        self.selected = [selected]
//        if let row = self.main.firstIndex(where: {$0.hashValue == selected.hashValue}) {
//               main[row] = selected
//        }
    }
    
    mutating func selectNote(_ note: Note) {
        main.append(contentsOf: selected)
        selected = [note]
        main.remove(at: main.firstIndex(of: selected[0])!)
    }
}
