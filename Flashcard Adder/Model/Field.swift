//
//  Field.swift
//  
//
//  Created by Matthew Shu on 9/18/20.
//

import Foundation

struct Field: Codable {
    let name: String
    var text: String?
    
    var unwrappedText: String {
        text ?? ""
    }
}

extension Field {
    init(name: String) {
        self.name = name
    }
}
