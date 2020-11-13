//
//  Flashcard.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation
import os.log

protocol FlashcardDelegate: AnyObject {
    func noteTypeDidChange(flashcard: Flashcard, from: Note, to: Note)
    func deckDidChange(flashcard: Flashcard, from: Deck, to: Deck)
    func profileDidChange(flashcard: Flashcard, from: Profile, to: Profile)
    func flashcardDidCreate(flashcard: Flashcard)
}

struct Flashcard: Codable {
    var note: Note
    var deck: Deck
    var profile: Profile
    var referenceText: String
    weak var delegate: FlashcardDelegate?

    private enum CodingKeys: String, CodingKey {
        case note
        case deck
        case profile
        case referenceText
    }

    var noteTypeName: String {
        note.name
    }

    var deckName: String {
        deck.name
    }

    var profileName: String {
        profile.name
    }

    var fieldNames: [String] {
        note.fields.map {
            $0.name
        }
    }

    var fields: [Field] {
        note.fields
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

    init(note: Note? = nil, deck: Deck? = nil, profile: Profile? = nil, referenceText: String? = nil, delegate: FlashcardDelegate? = nil) {
        #if Action
        FlashcardSettings.registerDefaults()
        #endif
        self.note = note ?? FlashcardSettings.shared.defaultNoteType
        self.deck = deck ?? FlashcardSettings.shared.defaultDeck
        self.profile = profile ?? FlashcardSettings.shared.defaultAnkiProfile
        self.referenceText = referenceText ?? ""
        self.delegate = delegate

        delegate?.flashcardDidCreate(flashcard: self)
    }

    // Creates a new flashcard following previous settings
    // Revise to allow frozen fields/other options
    init(previous: Flashcard, delegate: FlashcardDelegate? = nil) {
        self.init(note: previous.note.copyRespectingFrozen(), deck: previous.deck, profile: previous.profile, referenceText: previous.referenceText, delegate: delegate)
    }

    // Not a computed property because it calls the mutating function checkNoteType
    mutating func getAnkiUrl() -> URL? {
        if !isValid {
            Logger.flashcard.error("Invalid anki url")
            return nil
        }

        checkNoteType()
        var ankiUrlString = "anki://x-callback-url/addnote?profile=\(profile.name)&type=\(note.name)&deck=\(deck.name)"
        ankiUrlString = note.fields.reduce(ankiUrlString) { fieldString, field -> String in
            "\(fieldString)&fld\(field.name)=\(field.text)"
        }
        #if Main
        ankiUrlString.append("&x-success=ankiadd://")
        #endif
        if let encodedAnkiUrlString = ankiUrlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            Logger.flashcard.error("Encoded anki url:\(encodedAnkiUrlString)")
            return URL(string: encodedAnkiUrlString)
        } else {
            return nil
        }
    }

    private mutating func checkNoteType() {
        if note.acceptsCloze && Cloze.highestCurrentCloze(text: note.fields[0].text) == nil {
            Logger.flashcard.info("No clozes detected in cloze type note, converting to default non-cloze type")
            updateNoteType(to: FlashcardSettings.shared.defaultNoteType)
        } else if !note.acceptsCloze && Cloze.highestCurrentCloze(text: note.fields[0].text) != nil {
            Logger.flashcard.info("Clozes detected in non-cloze type note, converting to default cloze type")
            updateNoteType(to: FlashcardSettings.shared.defaultClozeNoteType)
        }
    }

    mutating func updateNoteType(to noteType: Note) {
        if noteType != note {
            let oldNote = note
            note = noteType

            for count in noteType.fields.indices where count < oldNote.fields.count && !oldNote.fields[count].text.isEmpty {
                note.fields[count].text = oldNote.fields[count].text
                note.fields[count].isFrozen = oldNote.fields[count].isFrozen
            }

            delegate?.noteTypeDidChange(flashcard: self, from: oldNote, to: note)
        }
    }

    mutating func updateDeck(to deck: Deck) {
        let oldDeck = self.deck
        self.deck = deck

        delegate?.deckDidChange(flashcard: self, from: oldDeck, to: deck)
    }

    mutating func updateProfile(to profile: Profile) {
        let oldProfile = self.profile
        self.profile = profile

        delegate?.profileDidChange(flashcard: self, from: oldProfile, to: profile)
    }

    mutating func updateField(name: String, to text: String) {
        if let index = fieldNames.firstIndex(of: name) {
            note.fields[index].text = text
        } else {
            Logger.flashcard.error("Field \(name) does not exist. \(text) not updated")
        }
    }

    mutating func updateField(index: Int, to text: String) {
        note.fields[index].text = text
    }

    mutating func toggleFrozenField(name: String, to isFrozen: Bool) {
        if let index = fieldNames.firstIndex(of: name) {
            note.fields[index].isFrozen = isFrozen
        } else {
            Logger.flashcard.error("Field \(name) does not exist.")
        }
    }
}
