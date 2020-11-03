//
//  Field.swift
//  
//
//  Created by Matthew Shu on 9/18/20.
//

import Foundation

struct Field: Codable {
    enum FieldType: String, Codable {
        case cloze, tag, normal
    }

    let name: String
    var text: String
    var fieldType: FieldType

    init(name: String, text: String = "", fieldType: FieldType = .normal) {
        self.name = name
        self.text = text
        self.fieldType = fieldType
    }
}
