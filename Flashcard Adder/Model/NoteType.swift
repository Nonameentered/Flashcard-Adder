//
//  NoteType.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation

struct NoteType: Codable {
    let name: String
    let fieldDefaults: [Field]
    let acceptsCloze: Bool
    
    init(name: String, fieldDefaults: [Field], acceptsCloze: Bool = false) {
        self.name = name
        self.fieldDefaults = fieldDefaults
        self.acceptsCloze = acceptsCloze
    }
}
