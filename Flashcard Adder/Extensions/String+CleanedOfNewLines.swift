//
//  String+CleanedOfNewLines.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/31/20.
//

import Foundation

public extension String {
    var cleanedOfNewLines: Self {
        self.replacingOccurrences(of: "-\\s{1,}", with: "", options: .regularExpression).replacingOccurrences(of: "\\s{1,}", with: " ", options: .regularExpression)
    }
}
