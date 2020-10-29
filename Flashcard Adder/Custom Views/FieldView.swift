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
    init(fieldName: String, axis: NSLayoutConstraint.Axis = .horizontal) {
        super.init(frame: .zero)
        setUpView(fieldName: fieldName, axis: axis)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(fieldName: String, axis: NSLayoutConstraint.Axis) {
        titleLabel = UILabel()
        titleLabel.text = fieldName
        textView = EditTextView()
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingTail
        addArrangedSubview(titleLabel)
        addArrangedSubview(textView)
        self.axis = axis
        spacing = 10
    }
}

class NoteView: UIStackView {
    var titleView: FieldStackView
    var fieldViews: [FieldStackView]
    
    init() {
        super.init(frame: .zero)
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(fieldName: String, axis: NSLayoutConstraint.Axis) {
        titleLabel = UILabel()
        titleLabel.text = fieldName
        textView = EditTextView()
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingTail
        addArrangedSubview(titleLabel)
        addArrangedSubview(textView)
        self.axis = axis
        spacing = 10
    }
}
