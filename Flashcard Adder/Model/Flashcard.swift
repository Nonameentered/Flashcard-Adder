//
//  Flashcard.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation

protocol FlashcardDelegate {
    func noteTypeDidChange(flashcard: Flashcard, from: NoteType, to: NoteType)
    func deckDidChange(flashcard: Flashcard, from: Deck, to: Deck)
    func flashcardAddDidFail(flashcard: Flashcard)
    func flashcardAddDidSucceed(flashcard: Flashcard)
}

struct Flashcard {
    let originalText: String
    var fields: [Field]
    var noteType: NoteType
    var deck: Deck
    var profile: Profile
    var surroundingText: String
    var delegate: FlashcardDelegate?
    
    init(originalText: String, surroundingText: String? = nil) {
        self.originalText = originalText
        noteType = FlashcardSettings.shared.defaultNoteType
        deck = FlashcardSettings.shared.defaultDeck
        profile = FlashcardSettings.shared.ankiProfile
        fields = noteType.fieldDefaults
        fields[0].text = originalText
        self.surroundingText = surroundingText ?? ""
    }
    
    init() {
        self.init(originalText: "")
    }
    
    var ankiUrl: URL? {
        if !isValid {
            print("INVALID")
            return nil
        }
        
        var ankiUrlString = "anki://x-callback-url/addnote?profile=\(profile.name)&type=\(noteType.name)&deck=\(deck.name)"
        ankiUrlString = self.fields.reduce(ankiUrlString) { fieldString, field -> String in
            "\(fieldString)&fld\(field.name)=\(field.text)"
        }
//        ankiUrlString.append("&tags=\(selectedTags.trimmingCharacters(in: .whitespaces))")
        ankiUrlString.append("&x-success=ankiadd://")
        if let encodednkiUrlString = ankiUrlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            print(encodednkiUrlString)
            return URL(string: encodednkiUrlString)
        } else {
            return nil
        }
    }
    
    var typeName: String {
        return noteType.name
    }
    
    var deckName: String {
        return deck.name
    }
    
    var fieldNames: [String] {
        return fields.map {
            $0.name
        }
    }
    
    var isValid: Bool {
        if fields[0].text == "" {
            if fields[1].text == "" {
                return noteType.acceptsCloze
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    /*
    mutating func convertClozeToBasic() {
        if type == "Cloze" && frontText.text.countInstances(of: "{{c") == 0 {
            type = "Basic"
            typeButton.setTitle("Type: " + type, for: .normal)
            fields = noteTypes[type] ?? ["Front", "Back"]
        }
    }
    */
    
    mutating func updateNoteType(to noteType: NoteType) {
        let oldNoteType = self.noteType
        self.noteType = noteType
        
        var newFields: [Field] = []
        for (count, var field) in noteType.fieldDefaults.enumerated() {
            if count < fields.count, !fields[count].text.isEmpty {
                field.text = fields[count].text
            }
            newFields.append(field)
        }
        fields = newFields
        
        delegate?.noteTypeDidChange(flashcard: self, from: oldNoteType, to: noteType)
    }
    
    mutating func updateDeck(to deck: Deck) {
        let oldDeck = self.deck
        self.deck = deck
        
        delegate?.deckDidChange(flashcard: self, from: oldDeck, to: deck)
    }
    
    mutating func updateField(with name: String, to text: String) {
        if let index = fieldNames.firstIndex(of: name) {
            fields[index].text = text
        } else {
            print("FIELD DOESN'T EXIST")
        }
    }
    
    // Maybe should be stricter/more elegant
    mutating func updateFields(to fields: [Field]) {
        self.fields = fields
    }
    
    /*
     func insertCloze(sequential: Bool = true, cloze: Cloze, textRange: Range) {
         if let textRange = frontTextView.selectedTextRange {
             clozeText = frontTextView.text(in: textRange)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
             if hintText != "::" {
                 cloze = "{{c\(clozeCounter)::\(clozeText)\(hintText)}}"
             } else {
                 cloze = "{{c\(clozeCounter)::\(clozeText)}}"
             }
            
             frontTextView.replace(textRange, withText: cloze)
         }
     }
     */
}
