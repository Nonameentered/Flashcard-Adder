//
//  ProfileViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/26/20.
//

import Foundation

struct AttributedProfile: AttributedOption {
    let source: Profile
    let selected: Profile
    var isDefault: Bool {
        source == FlashcardSettings.shared.defaultAnkiProfile
    }
}

struct Manager {
    
}

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
    }
    mutating func select(_ item: Profile) {
        selected = item
        generateAll()
        controllerDelegate.profileChanged(selected)
    }
    
    mutating func makeDefault(_ item: AttributedProfile) {
        FlashcardSettings.shared.defaultAnkiProfile = item.source
        // Duplicated with move function
        // Maybe could be replaced by call to generateAll?
        if !item.isDefault, let moved = main.moved(item, to: 0) {
            print(all)
            print(usual)
            print(moved)
            all = usual + moved
        }
        delegate?.updateList(animatingDifferences: false)
    }
    
    typealias attributedSourceType = AttributedProfile
    
    
}
