//
//  NoteType.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation

struct Note: Codable {
    let name: String
    var fields: [Field]
    
    init(name: String, fields: [Field]) {
        self.name = name
        self.fields = fields
    }
    
    var acceptsCloze: Bool {
        fields.contains {
            $0.fieldType == .cloze
        }
    }
}