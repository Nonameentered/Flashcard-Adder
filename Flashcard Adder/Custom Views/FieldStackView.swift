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
    var starButton: StarButton? = nil
    
    init(fieldName: String, text: String? = nil, axis: NSLayoutConstraint.Axis = .horizontal, oneLine: Bool = true, addStar: Bool = false) {
        super.init(frame: .zero)
        setUpView(fieldName: fieldName, axis: axis, oneLine: oneLine, addStar: addStar)
        if text != nil {
            textView.text = text
        }
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView(fieldName: String, axis: NSLayoutConstraint.Axis, oneLine: Bool, addStar: Bool) {
        titleLabel = UILabel()
        titleLabel.text = fieldName
        textView = EditTextView()

        // This makes sure everything stays on line when on a horizontal axis
        if oneLine {
            textView.textContainer.maximumNumberOfLines = 1
            textView.textContainer.lineBreakMode = .byTruncatingTail
        }
        
        addArrangedSubview(titleLabel)
        if addStar {
            starButton = StarButton()
            if let starButton = starButton {
                let buttonFieldStack = UIStackView(arrangedSubviews: [starButton, textView])
                buttonFieldStack.axis = .horizontal
                buttonFieldStack.distribution = UIStackView.Distribution.fillProportionally
                buttonFieldStack.spacing = 10
                addArrangedSubview(buttonFieldStack)
            }
        } else {
            addArrangedSubview(textView)
        }
        self.axis = axis
        spacing = 10
    }
}
