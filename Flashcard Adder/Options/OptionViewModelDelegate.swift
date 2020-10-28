//
//  OptionViewModelDelegate.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

protocol OptionViewModelDelegate {
    func updateList(animatingDifferences: Bool)
    func showEditDeck(current: Deck)
    func showEditProfile(current: Profile)
    func showEditNote(current: Note)
    func showAddDeck()
    func showAddProfile()
    func showAddNote()
}
