//
//  NoteType.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation

struct Note: Option {
    static let typeName = "Note Type"
    
    static let typeNamePlural = "Note Types"
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.name == rhs.name && lhs.fields == rhs.fields
    }
    
    static func ~= (lhs: Note, rhs: Note) -> Bool {
        lhs.name == rhs.name && lhs.fields ~= rhs.fields
    }
    
    let name: String
    var fields: [Field]
    
    init(name: String) {
        self.init(name: name, fields: [Field(name: "Front"), Field(name: "Back")])
    }
    
    init(name: String, fields: [Field]) {
        self.name = name
        self.fields = fields
    }
    
    var acceptsCloze: Bool {
        fields.contains {
            $0.fieldType == .cloze
        }
    }
    
    func copyRespectingFrozen() -> Note {
        Note(name: name, fields: fields.map {
            Field(name: $0.name, text: $0.isFrozen ? $0.text : "", fieldType: $0.fieldType, isFrozen: $0.isFrozen)
        })
    }
    
    func cleanedCopyWithoutText() -> Note {
        Note(name: self.name, fields: self.fields.map { Field(name: $0.name, text: "", fieldType: $0.fieldType, isFrozen: $0.isFrozen) } )
    }
}
