//
//  BorderedTextField.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/29/20.
//

import UIKit

class BorderedTextField: UITextField {
    init() {
        super.init(frame: .zero)
        setUpField()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpField() {
        backgroundColor = FlashcardSettings.Colors.backgroundColor
        textColor = FlashcardSettings.Colors.textColor

        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = FlashcardSettings.Colors.tintColor!.cgColor
    }
}
