//
//  EditFieldTextView.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//  Copyright © 2020 Technaplex. All rights reserved.
//

import UIKit

class EditTextView: UITextView {
    init() {
        super.init(frame: .zero, textContainer: nil)
        setUpView()
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    private func setUpView() {
        backgroundColor = FlashcardSettings.Colors.backgroundColor
        textColor = FlashcardSettings.Colors.textColor
        font = FlashcardSettings.Fonts.regularFont

        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = FlashcardSettings.Colors.tintColor!.cgColor
        isScrollEnabled = false
    }
}
