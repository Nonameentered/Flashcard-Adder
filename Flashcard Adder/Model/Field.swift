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

struct Field: Codable {
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
    
    var clozeInstances: Int {
        return text.countInstances(of: Cloze.identifier)
    }
    
    mutating func createCloze(sequential: Bool = true, cloze: Cloze, textRange: Range<String.Index>) {
        text.replaceSubrange(textRange, with: cloze.clozeString(with: clozeInstances))
        delegate?.clozeDidCreate(self, changeNoteType: !(fieldType == .cloze))
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case text
        case fieldType
    }
}
