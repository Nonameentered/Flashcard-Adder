//
//  Field.swift
//  
//
//  Created by Matthew Shu on 9/18/20.
//

import Foundation

struct Field: Codable, Hashable {
    static func == (lhs: Field, rhs: Field) -> Bool {
        lhs.name == rhs.name && lhs.text == rhs.text && lhs.fieldType == rhs.fieldType && lhs.isFrozen == rhs.isFrozen
    }
    
    static func ~= (lhs: Field, rhs: Field) -> Bool {
        lhs.name == rhs.name && lhs.fieldType == rhs.fieldType
    }
    
    enum FieldType: String, Codable {
        case cloze, tag, normal
    }
    
    let name: String
    var text: String
    let fieldType: FieldType
    var isFrozen: Bool
    
    
    init(name: String, text: String = "", fieldType: FieldType = .normal, isFrozen: Bool = false) {
        self.name = name
        self.text = text
        self.fieldType = fieldType
        self.isFrozen = isFrozen
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case text
        case fieldType
        case isFrozen
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(text)
        hasher.combine(fieldType)
        hasher.combine(isFrozen)
    }
}

extension Array where Element == Field {
    static func ~= (lhs: Array<Field>, rhs: Array<Field>) -> Bool {
        if rhs.count == lhs.count {
            for (ele1, ele2) in zip(lhs, rhs) {
                if !(ele1 ~= ele2) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
}
