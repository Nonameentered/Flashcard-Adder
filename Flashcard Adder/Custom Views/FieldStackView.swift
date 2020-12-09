//
//  FieldStackView.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/29/20.
//

import UIKit

class FieldStackView: UIStackView {
    var titleLabel: UILabel!
    var textView: EditTextView!
    var starButton: StarButton!
    weak var delegate: FieldStackViewDelegate?

    init(fieldName: String, text: String? = nil, axis: NSLayoutConstraint.Axis = .vertical, oneLine: Bool = true, showStar: Bool = true, isFrozen: Bool? = nil, delegate: FieldStackViewDelegate? = nil, textViewDelegate: UITextViewDelegate? = nil) {
        self.delegate = delegate
        super.init(frame: .zero)
        setUpView(fieldName: fieldName, axis: axis, oneLine: oneLine)
        if let text = text {
            textView.text = text
        }
        if let isFrozen = isFrozen {
            starButton.isSelected = isFrozen
        }
        self.textView.delegate = textViewDelegate
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView(fieldName: String, axis: NSLayoutConstraint.Axis, oneLine: Bool) {
        self.axis = axis
        spacing = 10
        titleLabel = UILabel()
        titleLabel.text = fieldName
        textView = EditTextView()

        // This makes sure everything stays on line when on a horizontal axis
        if oneLine {
            textView.textContainer.maximumNumberOfLines = 1
            textView.textContainer.lineBreakMode = .byTruncatingTail
        }

        addArrangedSubview(titleLabel)
        starButton = StarButton(action: UIAction { _ in
            self.delegate?.didToggle(view: self, starState: self.starButton.isSelected)
        })
        let buttonFieldStack = UIStackView(arrangedSubviews: [starButton, textView])
        buttonFieldStack.axis = .horizontal
        buttonFieldStack.distribution = UIStackView.Distribution.fillProportionally
        buttonFieldStack.spacing = 10
        addArrangedSubview(buttonFieldStack)
    }
}

protocol FieldStackViewDelegate: AnyObject {
    func didToggle(view: FieldStackView, starState: Bool)
}
