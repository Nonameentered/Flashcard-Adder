//
//  Section.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

struct Section<Attributed: AttributedOption>: Hashable {
    var title: String
    var items: [Attributed]

    init(title: String, items: [Attributed]) {
        self.title = title
        self.items = items
      }
}
