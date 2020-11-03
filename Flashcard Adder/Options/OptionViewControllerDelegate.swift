//
//  OptionViewControllerDelegate.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

protocol OptionViewControllerDelegate: AnyObject {
    func profileChanged(_ profile: Profile)
    func deckChanged(_ deck: Deck)
    func noteChanged(_ note: Note)
}
