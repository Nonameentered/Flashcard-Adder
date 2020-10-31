//
//  NoteViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

struct NoteViewModel: OptionViewModel {
    var all: [AttributedNote] {
        didSet {
            FlashcardSettings.shared.noteTypes = all.map { $0.source }
        }
    }
    
    var selected: Note
    
    var delegate: OptionViewModelDelegate?
    
    let controllerDelegate: OptionViewControllerDelegate
    
    var main: [AttributedNote] {
        all.filter { !$0.isDefault }
    }
    
    var usual: [AttributedNote] {
        all.filter { $0.isDefaultNormal }
    }
    
    var usualCloze: [AttributedNote] {
        all.filter { $0.isDefaultCloze }
    }
    
    var sections: [Section<AttributedNote>] {
        [Section(title: "Default Note", items: usual), Section(title: "Default Cloze Note", items: usualCloze), Section(title: "Other \(AttributedNote.sourceType.typeNamePlural)", items: main)]
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
        print("MAKING \(item) DEFAUlt")
        if item.source.acceptsCloze {
            makeClozeDefault(item)
        } else {
            makeNormalDefault(item)
        }
    }
    
    mutating func makeNormalDefault(_ item: AttributedNote) {
        FlashcardSettings.shared.defaultNoteType = item.source
        delegate?.updateList(animatingDifferences: false)
    }
    
    mutating func makeClozeDefault(_ item: AttributedNote) {
        FlashcardSettings.shared.defaultClozeNoteType = item.source
        delegate?.updateList(animatingDifferences: false)
    }
    
    mutating func move(_ item: AttributedNote, to indexPath: IndexPath) {
        if indexPath.section == 0 || indexPath.section == 1 {
            makeDefault(item)
        } else {
            if !item.isDefault, !item.isDefaultCloze, let moved = main.moved(item, to: indexPath.row) {
                all = usual + usualCloze + moved
            }
            delegate?.updateList(animatingDifferences: false)
        }
    }
}
