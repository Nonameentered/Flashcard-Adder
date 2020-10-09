//
//  Cloze.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 9/27/20.
//

import Foundation

/*
struct ClozeManager {
    var clozes: [Cloze]
    
    var clozeCount: Int {
        return clozes.count
    }
    
    func newCloze(sequential: Bool = true, subject: String, hint: String) -> String {
        return "{{c\(clozeCount + 1)::\(subject)::\(hint)}}"
    }
}
*/

struct Cloze {
    let subject: String
    let hint: String?
    
    func clozeString(with count: Int) -> String {
        if let hint = hint {
            return "{{c\(count)::\(subject)::\(hint)}}"
        } else {
            return "{{c\(count)::\(subject)}}"
        }
    }
}

extension Cloze {
    init(subject: String) {
        self.subject = subject
        self.hint = nil
    }
}
