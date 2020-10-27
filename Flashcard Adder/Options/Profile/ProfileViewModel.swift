//
//  ProfileViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/26/20.
//

import Foundation

struct ProfileViewModel: OptionViewModel {
    var all: [AttributedProfile] {
        didSet {
            FlashcardSettings.shared.ankiProfiles = all.map { $0.source }
        }
    }

    var selected: Profile
    var delegate: OptionViewModelDelegate?
    var controllerDelegate: OptionViewControllerDelegate

    init(selected: Profile, controllerDelegate: OptionViewControllerDelegate) {
        self.selected = selected
        self.controllerDelegate = controllerDelegate
        all = []
        generateAll()
    }

    mutating func generateAll() {
        all = FlashcardSettings.shared.ankiProfiles.map {
            AttributedProfile(source: $0, selected: selected)
        }
        controllerDelegate.profileChanged(selected)
    }

    mutating func makeDefault(_ item: AttributedProfile) {
        FlashcardSettings.shared.defaultAnkiProfile = item.source
        delegate?.updateList(animatingDifferences: false)
    }
}
