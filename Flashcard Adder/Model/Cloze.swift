//
//  Cloze.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 9/27/20.
//

import Foundation

struct Cloze: Codable {
    let subject: String
    let hint: String?
    
    func clozeString(with count: Int) -> String {
        if let hint = hint {
            return "{{c\(count)::\(subject)::\(hint)}}"
        } else {
            return "{{c\(count)::\(subject)}}"
        }
    }
    
    static let identifier = "{{c"
}

extension Cloze {
    init(subject: String) {
        self.subject = subject
        self.hint = nil
    }
}
