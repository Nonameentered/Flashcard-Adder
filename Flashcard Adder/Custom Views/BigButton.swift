//
//  RoundBorderButton.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//  Copyright © 2020 Technaplex. All rights reserved.
//

import UIKit

class BigButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setUpView(title: title)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    private func setUpView(title: String? = nil) {
        if let title = title {
            setTitle(title, for: .normal)
        }
        backgroundColor = FlashcardSettings.Colors.backgroundColor
        setTitleColor(FlashcardSettings.Colors.tintColor, for: .normal)
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = FlashcardSettings.Colors.tintColor!.cgColor

        adjustsImageWhenDisabled = true
        adjustsImageWhenHighlighted = true
    }
}

extension UIButton {
    static func createStandardButton(withTitle: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(withTitle, for: .normal)
        button.backgroundColor = FlashcardSettings.Colors.backgroundColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = FlashcardSettings.Colors.tintColor!.cgColor
        button.adjustsImageWhenDisabled = true
        button.adjustsImageWhenHighlighted = true
        return button
    }
}
