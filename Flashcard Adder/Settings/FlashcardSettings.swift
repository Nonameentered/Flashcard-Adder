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
        let suiteName = "group.com.technaplex.Flashcard-Adder"
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
    
    enum ElementKind {
        static let sectionHeader = "section-header-element-kind"
    }
    
    enum Key: String, Codable {
        case defaultAnkiProfile, defaultNoteType, defaultClozeNoteType, defaultDeck, noteTypes, decks, ankiProfiles
    }
    
    static func registerDefaults() {
        let defaults: [String: Any] = [Key.defaultAnkiProfile.rawValue: encodeCodable(for: Profile(name: "User 1"))!,
                                       Key.defaultNoteType.rawValue: encodeCodable(for: Note(name: "Basic", fields: [Field(name: "Front"), Field(name: "Back")]))!,
                                       Key.defaultClozeNoteType.rawValue: encodeCodable(for: Note(name: "Cloze", fields: [Field(name: "Text", fieldType: .cloze), Field(name: "Extra")]))!,
                                       Key.defaultDeck.rawValue: encodeCodable(for: Deck(name: "Default"))!,
                                       Key.noteTypes.rawValue: encodeCodable(for: [Note(name: "Basic", fields: [Field(name: "Front"), Field(name: "Back")]), Note(name: "Cloze", fields: [Field(name: "Text"), Field(name: "Extra")])])!,
                                       Key.decks.rawValue: encodeCodable(for: [Deck(name: "Default")])!,
                                       Key.ankiProfiles.rawValue: encodeCodable(for: [Profile(name: "User 1")])!]
        FlashcardSettings.store.register(defaults: defaults)
        Logger.settings.info("Register defaults")
        FlashcardSettings.store.synchronize()
    }
    
    // Provided for developer convenience since UserDefaults don't always seem to be deleted when apps are deleted
    static func flushSettings() {
        FlashcardSettings.store.set(nil, forKey: Key.defaultAnkiProfile.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.defaultClozeNoteType.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.defaultNoteType.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.defaultDeck.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.noteTypes.rawValue)
        FlashcardSettings.store.set(nil, forKey: Key.decks.rawValue)
        FlashcardSettings.store.synchronize()
    }
    
    var defaultAnkiProfile: Profile {
        get {
            return FlashcardSettings.codable(for: Key.defaultAnkiProfile.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultAnkiProfile.rawValue, newValue)
            
            FlashcardSettings.store.synchronize()
        }
    }
    
    var defaultNoteType: Note {
        get {
            return FlashcardSettings.codable(for: Key.defaultNoteType.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultNoteType.rawValue, newValue)
            Logger.settings.info("Set default note type")
            
            FlashcardSettings.store.synchronize()
        }
    }
    
    var defaultClozeNoteType: Note {
        get {
            return FlashcardSettings.codable(for: Key.defaultClozeNoteType.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultClozeNoteType.rawValue, newValue)
            
            FlashcardSettings.store.synchronize()
        }
    }
    
    var defaultDeck: Deck {
        get {
            return FlashcardSettings.codable(for: Key.defaultDeck.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.defaultDeck.rawValue, newValue)
            
            FlashcardSettings.store.synchronize()
        }
    }
    
    var noteTypes: [Note] {
        get {
            return FlashcardSettings.codable(for: Key.noteTypes.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.noteTypes.rawValue, newValue)
            FlashcardSettings.store.synchronize()
            Logger.settings.info("Set note types")
        }
    }
    
    var decks: [Deck] {
        get {
            return FlashcardSettings.codable(for: Key.decks.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.decks.rawValue, newValue)
            FlashcardSettings.store.synchronize()
            Logger.settings.info("Set decks \(newValue)")
        }
    }
    
    var ankiProfiles: [Profile] {
        get {
            return FlashcardSettings.codable(for: Key.ankiProfiles.rawValue)!
        }
        set {
            FlashcardSettings.setCodable(for: Key.ankiProfiles.rawValue, newValue)
            FlashcardSettings.store.synchronize()
            Logger.settings.info("Set anki profiles \(newValue)")
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
