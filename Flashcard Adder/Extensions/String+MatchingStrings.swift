//
//  String+MatchingStrings.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/14/20.
//

import Foundation

// Taken from Lars Blumberg here: https://stackoverflow.com/a/40040472/14362235
extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))
        return results.map { result in
            (0 ..< result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}
