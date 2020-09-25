//
//  NoteType.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//

import Foundation

struct NoteType: Codable {
    let name: String
    let fields: [Field]
}
