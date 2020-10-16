//
//  FlashcardSettings.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/16/20.
//

import Foundation

final class FlashcardSettings {
    static let shared = FlashcardSettings()
    private init() {}
    
    static var store: UserDefaults = {
        let appIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as! String
        let suiteName = "\(appIdentifierPrefix)group.\(Bundle.main.bundleIdentifier!)"
        return UserDefaults(suiteName: suiteName)!
    }()
    
    enum Segues {
        static let goToAddNote = "goToAddNote"
        static let unwindToSelectNote = "unwindToSelectNote"
        static let unwindToFlashcardFromNoteList = "unwindToFlashcardFromNoteList"
    }
    
    enum Key {
        static let ankiProfile = "ankiProfile"
        static let defaultNoteType = "defaultNoteType"
        static let defaultClozeNoteType = "defaultClozeNoteType"
        static let defaultDeck = "defaultDeck"
        static let noteTypes = "noteTypes"
        static let decks = "decks"
    }
    
    static func registerDefaults() {
        let defaults: [String: Data] = [Key.ankiProfile: encodeCodable(for: Profile(name: "User 1"))!,
                                        Key.defaultNoteType: encodeCodable(for: Note(name: "Basic", fields: [Field(name: "Front"), Field(name: "Back")]))!,
                                        Key.defaultClozeNoteType: encodeCodable(for: Note(name: "Cloze", fields: [Field(name: "Text"), Field(name: "Extra")]))!,
                                        Key.defaultDeck: encodeCodable(for: Deck(name: "Default"))!]
        FlashcardSettings.store.register(defaults: defaults)
    }
    
    var ankiProfile: Profile {
        get {
            return FlashcardSettings.codable(for: Key.ankiProfile) ?? Profile(name: "User 1")
        }
        set {
            FlashcardSettings.setCodable(for: Key.ankiProfile, newValue)
        }
    }
    
    var defaultNoteType: Note {
        get {
            return FlashcardSettings.codable(for: Key.defaultNoteType) ?? Note(name: "Basic", fields: [Field(name: "Front"), Field(name: "Back")])
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultNoteType, newValue)
        }
    }
    
    var defaultClozeNoteType: Note {
        get {
            return FlashcardSettings.codable(for: Key.defaultNoteType) ?? Note(name: "Cloze", fields: [Field(name: "Text"), Field(name: "Extra")])
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultNoteType, newValue)
        }
    }
    
    var defaultDeck: Deck {
        get {
            return FlashcardSettings.codable(for: Key.defaultDeck) ?? Deck(name: "Default")
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultDeck, newValue)
        }
    }
    
    var noteTypes: [Note] {
        get {
            return FlashcardSettings.codable(for: Key.noteTypes) ?? [Note(name: "Basic", fields: [Field(name: "Front"), Field(name: "Back")]), Note(name: "Cloze", fields: [Field(name: "Text"), Field(name: "Extra")])]
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultNoteType, newValue)
        }
    }
    
    var decks: [Deck] {
        get {
            return FlashcardSettings.codable(for: Key.decks) ?? [Deck(name: "Default")]
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultNoteType, newValue)
        }
    }
}

private extension FlashcardSettings {
    static func string(for key: String) -> String? {
        return FlashcardSettings.store.string(forKey: key)
    }
    
    static func setString(for key: String, _ value: String?) {
        FlashcardSettings.store.set(value, forKey: key)
    }

    static func bool(for key: String) -> Bool {
        return FlashcardSettings.store.bool(forKey: key)
    }

    static func setBool(for key: String, _ flag: Bool) {
        FlashcardSettings.store.set(flag, forKey: key)
    }
    
    static func encodeCodable<T: Codable>(for value: T) -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(value)
    }
    
    static func decodeCodable<T: Codable>(for value: Data) -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: value)
    }
    
    static func codable<T: Codable>(for key: String) -> T? {
        if let savedCodable = FlashcardSettings.store.object(forKey: key) as? Data {
            return decodeCodable(for: savedCodable)
        }
        return nil
    }
    
    static func setCodable<T: Codable>(for key: String, _ value: T) {
        FlashcardSettings.store.set(encodeCodable(for: value), forKey: key)
    }
}
