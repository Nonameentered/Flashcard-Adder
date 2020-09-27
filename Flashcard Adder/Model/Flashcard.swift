//
//  Flashcard.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation

struct Flashcard {
    let originalText: String
    var fields: [Field]
    var noteType: NoteType
    var selectedDeck: Deck
    var profile: Profile
    
    init(originalText: String) {
        self.originalText = originalText
        noteType = FlashcardSettings.shared.defaultNoteType
        selectedDeck = FlashcardSettings.shared.defaultDeck
        profile = FlashcardSettings.shared.ankiProfile
        fields = noteType.fields
        fields[0].text = originalText
        
    }
    
    var ankiUrl: URL? {
        let ankiUrlString = "anki://x-callback-url/addnote?profile=\(profile)&type=\(noteType)&deck=\(selectedDeck)"
        return URL(string: ankiUrlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)
    }
    
}


