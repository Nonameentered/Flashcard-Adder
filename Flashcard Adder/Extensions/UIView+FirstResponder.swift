//
//  UIView+FirstResponder.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 9/27/20.
//

import UIKit

// Taken from Thomas Miller here: https://stackoverflow.com/a/1823360/14362235
extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}
