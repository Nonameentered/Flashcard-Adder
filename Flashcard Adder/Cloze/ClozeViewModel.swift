//
//  ClozeViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/20/20.
//

import UIKit

struct ClozeViewModel {
    private(set) var cloze: String
    private(set) var hint: String
    private(set) var referenceSpaceText: String
    let beginWithHint: Bool
    let savedRange: UITextRange?

    init(cloze: String? = nil, hint: String? = nil, referenceSpaceText: String? = nil, savedRange: UITextRange? = nil, beginWithHint: Bool? = nil) {
        self.cloze = cloze ?? ""
        self.hint = hint ?? ""
        self.referenceSpaceText = referenceSpaceText ?? ""
        self.savedRange = savedRange
        self.beginWithHint = beginWithHint ?? !(cloze?.isEmpty ?? true)
    }

    mutating func update(cloze: String? = nil, hint: String? = nil, referenceSpaceText: String? = nil) {
        if let cloze = cloze {
            self.cloze = cloze
        }
        if let hint = hint {
            self.hint = hint
        }
        if let referenceSpaceText = referenceSpaceText {
            self.referenceSpaceText = referenceSpaceText
        }
    }
}
