//
//  Collection+SafeSubscript.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 11/2/20.
//

import Foundation

// Taken from Wendy Liga https://medium.com/flawless-app-stories/say-goodbye-to-index-out-of-range-swift-eca7c4c7b6ca
extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
