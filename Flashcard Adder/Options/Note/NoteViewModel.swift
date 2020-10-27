//
//  NoteViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

struct NoteViewModel: OptionViewModel {
    var all: [AttributedNote]
    
    var selected: Note
    
    var delegate: OptionViewModelDelegate?
    
    let controllerDelegate: OptionViewControllerDelegate
    
    var main: [AttributedNote] {
        all.filter { !$0.isDefault && !$0.isDefaultCloze }
    }
    
    var usualCloze: [AttributedNote] {
        all.filter { $0.isDefaultCloze }
    }
    
    var sections: [Section<AttributedNote>] {
        [Section(title: "Default Note", items: usual), Section(title: "Default Cloze Note", items: usualCloze), Section(title: "Other \(attributedSourceType.sourceType.typeNamePlural)", items: main)]
    }
    
    init(selected: Note, controllerDelegate: OptionViewControllerDelegate) {
        self.selected = selected
        self.controllerDelegate = controllerDelegate
        all = []
        generateAll()
    }
    
    mutating func generateAll() {
        all = FlashcardSettings.shared.noteTypes.map {
            AttributedNote(source: $0, selected: selected)
        }
        controllerDelegate.noteChanged(selected)
    }
    
    mutating func makeDefault(_ item: AttributedNote) {
        FlashcardSettings.shared.defaultNoteType = item.source
        delegate?.updateList(animatingDifferences: false)
    }
    
    
}
