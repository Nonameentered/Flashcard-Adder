//
//  FlashcardSettings.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/16/20.
//

import Foundation
import os.log

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
        static let unwindToFlashcardFromDeckList = "unwindToFlashcardFromDeckList"
        static let goToClozeWithEdit = "goToClozeWithEdit"
        static let goToClozeWithBackText = "goToClozeWithBackText"
    }
    
    enum Colors {
        static let backgroundColor = "backgroundColor"
    }
    
//    enum Key {
//        static let ankiProfile = "ankiProfile"
//        static let defaultNoteType = "defaultNoteType"
//        static let defaultClozeNoteType = "defaultClozeNoteType"
//        static let defaultDeck = "defaultDeck"
//        static let noteTypes = "noteTypes"
//        static let decks = "decks"
//    }
    
    enum Key: String, Codable {
        case ankiProfile, defaultNoteType, defaultClozeNoteType, defaultDeck, noteTypes, decks
    }
    
    static func registerDefaults() {
        let defaults: [String: Any] = [Key.ankiProfile.rawValue: encodeCodable(for: Profile(name: "User 1"))!,
                                        Key.defaultNoteType.rawValue: encodeCodable(for: Note(name: "Basic", fields: [Field(name: "Front"), Field(name: "Back")]))!,
                                        Key.defaultClozeNoteType.rawValue: encodeCodable(for: Note(name: "Cloze", fields: [Field(name: "Text"), Field(name: "Extra")]))!,
                                        Key.defaultDeck.rawValue: encodeCodable(for: Deck(name: "Default"))!,
                                        Key.noteTypes.rawValue: encodeCodable(for: [Note(name: "Basic", fields: [Field(name: "Front"), Field(name: "Back")]), Note(name: "Cloze", fields: [Field(name: "Text"), Field(name: "Extra")])])!,
                                        Key.decks.rawValue: encodeCodable(for: [Deck(name: "Default")])!]
        FlashcardSettings.store.register(defaults: defaults)
        Logger.settings.info("Register defaults")
    }
    
    // Provided for developer convenience since UserDefaults don't always seem to be deleted when apps are deleted
    static func flushSettings() {
        FlashcardSettings.store.set(nil, forKey: Key.ankiProfile.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.defaultClozeNoteType.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.defaultNoteType.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.defaultDeck.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.noteTypes.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.decks.rawValue)
    }
    
    var ankiProfile: Profile {
        get {
            return FlashcardSettings.codable(for: Key.ankiProfile.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.ankiProfile.rawValue, newValue)
        }
    }
    
    var defaultNoteType: Note {
        get {
            return FlashcardSettings.codable(for: Key.defaultNoteType.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultNoteType.rawValue, newValue)
            Logger.settings.info("Set default note type")
        }
    }
    
    var defaultClozeNoteType: Note {
        get {
            return FlashcardSettings.codable(for: Key.defaultNoteType.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultNoteType.rawValue, newValue)
        }
    }
    
    var defaultDeck: Deck {
        get {
            return FlashcardSettings.codable(for: Key.defaultDeck.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultDeck.rawValue, newValue)
        }
    }
    
    var noteTypes: [Note] {
        get {
            return FlashcardSettings.codable(for: Key.noteTypes.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.decks.rawValue, newValue)
            Logger.settings.info("Set note types")
        }
    }
    
    var decks: [Deck] {
        get {
            return FlashcardSettings.codable(for: Key.decks.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.decks.rawValue, newValue)
            Logger.settings.info("Set decks \(newValue)")
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
        Logger.settings.error("Encoding codable")
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
        Logger.settings.error("Failed to save codable for key \(key)")
        return nil
    }
    
    static func setCodable<T: Codable>(for key: String, _ value: T) {
        FlashcardSettings.store.set(encodeCodable(for: value), forKey: key)
    }
}
