//
//  UITextView+CleanUpErrantNewLines.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 12/9/20.
//

import UIKit

extension UITextView {
    func cleanUpErrantNewLines() {
        self.text = self.text.cleanedOfNewLines
    }
}
