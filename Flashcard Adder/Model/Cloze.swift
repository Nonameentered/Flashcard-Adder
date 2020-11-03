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

    func clozeString(with count: String) -> String {
        if let hint = hint {
            return "{{c\(count)::\(subject)::\(hint)}}"
        } else {
            return "{{c\(count)::\(subject)}}"
        }
    }

    static let identifier = "{{c"
    static let regexIdentifier = "\\{\\{c([0-9]+)"
}

extension Cloze {
    init(subject: String) {
        self.subject = subject
        self.hint = nil
    }

    static func highestCurrentCloze(text: String) -> Int? {
        let matches = text.matchingStrings(regex: regexIdentifier)

        let matchedClozeValues = matches.map { $0[1] }
        if let maxValue = matchedClozeValues.max(), let maxValueInt = Int(maxValue) {
            return maxValueInt
        } else {
            return nil
        }
    }
}
