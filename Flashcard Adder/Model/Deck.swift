//
//  Deck.swift
//  
//
//  Created by Matthew Shu on 9/18/20.
//

import Foundation

struct Deck: Codable, Hashable, Option {
    static let typeName: String = "Deck"
    static let typeNamePlural: String = "Decks"
    
    let name: String
}
