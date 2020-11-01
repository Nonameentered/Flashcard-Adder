//
//  String+MatchingStrings.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/14/20.
//

import Foundation

// Taken from Lars Blumberg here: https://stackoverflow.com/a/40040472/14362235
public extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}


public extension String {
    var replaceNewlinesWithSpaces: Self {
        self.replacingOccurrences(of: "-\\n", with: "", options: .regularExpression).replacingOccurrences(of: "\\n", with: " ", options: .regularExpression)
    }
    var newThing: Self {
        self
    }
}
