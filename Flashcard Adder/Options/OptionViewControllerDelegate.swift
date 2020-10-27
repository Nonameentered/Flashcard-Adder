//
//  OptionViewControllerDelegate.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

protocol OptionViewControllerDelegate {
    func profileChanged(_ profile: Profile)
    func deckChanged(_ deck: Deck)
}
