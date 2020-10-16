//
//  Field.swift
//  
//
//  Created by Matthew Shu on 9/18/20.
//

import Foundation

protocol FieldDelegate: Codable {
    func clozeDidCreate(_ field: Field, changeNoteType: Bool)
}

struct Field: Codable, Hashable {
    static func == (lhs: Field, rhs: Field) -> Bool {
        lhs.name == rhs.name && lhs.text == rhs.text && lhs.fieldType == rhs.fieldType
    }
    
    enum FieldType: String, Codable {
        case cloze, tag, normal
    }
    
    let name: String
    var text: String
    let fieldType: FieldType
    var delegate: FieldDelegate?
    
    
    init(name: String, text: String = "", fieldType: FieldType = .normal, delegate: FieldDelegate? = nil) {
        self.name = name
        self.text = text
        self.fieldType = fieldType
        self.delegate = delegate
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case text
        case fieldType
    }
    
    // Currently Unused
    var clozeInstances: Int {
        return Cloze.highestCurrentCloze(text: text) ?? 0
    }
    
    // Currently Unused
    mutating func createCloze(sequential: Bool = true, cloze: Cloze, textRange: Range<String.Index>) {
        text.replaceSubrange(textRange, with: cloze.clozeString(with: clozeInstances))
        delegate?.clozeDidCreate(self, changeNoteType: !(fieldType == .cloze))
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(text)
        hasher.combine(fieldType)
    }
}
