//
//  Option.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/25/20.
//

import Foundation

protocol Option: Codable, Hashable {
    var name: String { get }
    static var typeName: String { get }
    static var typeNamePlural: String { get }

    init(name: String)
}
