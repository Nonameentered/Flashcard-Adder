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
        lhs.name == rhs.name && lhs.fields == lhs.fields
    }
    
    static func ~= (lhs: Note, rhs: Note) -> Bool {
        lhs.name == rhs.name && lhs.fields ~= lhs.fields
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
}
