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
    init(fieldName: String, text: String? = nil, axis: NSLayoutConstraint.Axis = .horizontal, oneLine: Bool = true) {
        super.init(frame: .zero)
        setUpView(fieldName: fieldName, axis: axis, oneLine: oneLine)
        if text != nil {
            textView.text = text
        }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(fieldName: String, axis: NSLayoutConstraint.Axis, oneLine: Bool) {
        titleLabel = UILabel()
        titleLabel.text = fieldName
        textView = EditTextView()
        
        // This makes sure everything stays on line when on a horizontal axis
        if oneLine {
            textView.textContainer.maximumNumberOfLines = 1
            textView.textContainer.lineBreakMode = .byTruncatingTail
        }
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(textView)
        self.axis = axis
        spacing = 10
    }
}


