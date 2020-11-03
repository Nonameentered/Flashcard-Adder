//
//  Cloze.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 9/27/20.
//

import Foundation

public struct Cloze: Codable {
    let subject: String
    let hint: String?

    func clozeString(with count: Int) -> String {
        if let hint = hint {
            return "{{c\(count)::\(subject)::\(hint)}}"
        } else {
            return "{{c\(count)::\(subject)}}"
        }
    }

    func clozeString(with count: String) -> String {
        if let hint = hint {
            return "{{c\(count)::\(subject)::\(hint)}}"
        } else {
            return "{{c\(count)::\(subject)}}"
        }
    }

    static let identifier = "{{c"
    public static let regexIdentifier = "\\{\\{c([0-9]+)"
}

public extension Cloze {
    init(subject: String) {
        self.subject = subject
        self.hint = nil
    }
}
