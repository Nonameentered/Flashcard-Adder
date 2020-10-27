//
//  AttributedProfile.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

struct AttributedProfile: AttributedOption {
    let source: Profile
    let selected: Profile
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultAnkiProfile
    }
}
