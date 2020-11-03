//
//  OptionViewModelDelegate.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import Foundation

protocol OptionViewModelDelegate: AnyObject {
    func updateList(animatingDifferences: Bool)
}
