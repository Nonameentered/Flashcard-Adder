//
//  Flashcard.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation

protocol FlashcardDelegate {
    func noteTypeDidChange(flashcard: Flashcard, from: Note, to: Note)
    func deckDidChange(flashcard: Flashcard, from: Deck, to: Deck)
    func flashcardAddDidFail(flashcard: Flashcard)
    func flashcardAddDidSucceed(flashcard: Flashcard)
}

struct Flashcard: Codable {
    let originalText: String
    var note: Note
    var deck: Deck
    var profile: Profile
    var surroundingText: String
    var delegate: FlashcardDelegate?
    
    private enum CodingKeys: String, CodingKey {
        case originalText
        case note
        case deck
        case profile
        case surroundingText
    }
    
    var ankiUrl: URL? {
        if !isValid {
            print("INVALID")
            return nil
        }
        
        var ankiUrlString = "anki://x-callback-url/addnote?profile=\(profile.name)&type=\(note.name)&deck=\(deck.name)"
        ankiUrlString = self.note.fields.reduce(ankiUrlString) { fieldString, field -> String in
            "\(fieldString)&fld\(field.name)=\(field.text)"
        }
        ankiUrlString.append("&x-success=ankiadd://")
        if let encodedAnkiUrlString = ankiUrlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            print(encodedAnkiUrlString)
            return URL(string: encodedAnkiUrlString)
        } else {
            return nil
        }
    }
    
    var noteTypeName: String {
        return note.name
    }
    
    var deckName: String {
        return deck.name
    }
    
    var fieldNames: [String] {
        return note.fields.map {
            $0.name
        }
    }
    
    var isValid: Bool {
        if note.fields[0].text == "" {
            if note.fields[1].text == "" {
                return note.acceptsCloze
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    mutating func updateNoteType(to noteType: Note) {
        let oldNote = self.note
        self.note = noteType
        
        for (count, _) in noteType.fields.enumerated() {
            if count < oldNote.fields.count, !oldNote.fields[count].text.isEmpty {
                self.note.fields[count].text = oldNote.fields[count].text
            }
        }
        
        delegate?.noteTypeDidChange(flashcard: self, from: oldNote, to: note)
    }
    
    mutating func updateDeck(to deck: Deck) {
        let oldDeck = self.deck
        self.deck = deck
        
        delegate?.deckDidChange(flashcard: self, from: oldDeck, to: deck)
    }
    
    mutating func updateField(name: String, to text: String) {
        if let index = fieldNames.firstIndex(of: name) {
            note.fields[index].text = text
        } else {
            print("FIELD DOESN'T EXIST")
        }
    }
    
    // Currently Unused. I hope this can replace the Cloze section in AnkiViewController eventually
    mutating func insertCloze(sequential: Bool = true, cloze: Cloze, textRange: Range<String>) {
        if note.acceptsCloze {
            updateNoteType(to: FlashcardSettings.shared.defaultClozeNoteType)
        }
//         if let textRange = frontTextView.selectedTextRange {
//             clozeText = frontTextView.text(in: textRange)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//             if hintText != "::" {
//                 cloze = "{{c\(clozeCounter)::\(clozeText)\(hintText)}}"
//             } else {
//                 cloze = "{{c\(clozeCounter)::\(clozeText)}}"
//             }
//
//             frontTextView.replace(textRange, withText: cloze)
//         }
     }
}

extension Flashcard {
    init(originalText: String, surroundingText: String? = nil) {
        self.originalText = originalText
        note = FlashcardSettings.shared.defaultNoteType
        deck = FlashcardSettings.shared.defaultDeck
        profile = FlashcardSettings.shared.ankiProfile
        self.surroundingText = surroundingText ?? ""
        
        setFieldDelegates()
    }
    
    // Creates a new flashcard following previous settings
    init(previous: Flashcard) {
        self.init(originalText: "", note: previous.note, deck: previous.deck, profile: previous.profile, surroundingText: previous.surroundingText)
    }
    
    init() {
        self.init(originalText: "")
    }
}

extension Flashcard: FieldDelegate {
    // Currently Unused
    func clozeDidCreate(_ field: Field, changeNoteType: Bool) {
        print("CLOZE")
    }
    
    private mutating func setFieldDelegates() {
        note.fields = note.fields.map { var newField = $0; newField.delegate = self; return newField }
    }
}
