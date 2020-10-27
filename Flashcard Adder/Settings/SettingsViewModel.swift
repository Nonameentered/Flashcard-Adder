//
//  SettingsViewModel.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/18/20.
//

import Foundation

class SettingsViewModel {
    static let shared = SettingsViewModel()
    let flashcardOptions: [Setting]
    
    private init() {
        flashcardOptions = [Setting(name: .defaultAnkiProfile)]
    }
    
    func selected(setting: Setting) {
        
    }
}
