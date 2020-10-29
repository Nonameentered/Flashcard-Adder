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
    var titleView: FieldStackView!
    var fieldViews: [FieldStackView]!
    var addFieldButton: BigButton!
    
    init(axis: NSLayoutConstraint.Axis = .vertical) {
        super.init(frame: .zero)
        setUpView(axis: axis)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(axis: NSLayoutConstraint.Axis) {
        titleView = FieldStackView(fieldName: "Note Name")
        fieldViews = [FieldStackView(fieldName: "Field 1 Name"), FieldStackView(fieldName: "Field 2 Name")]
        addFieldButton = BigButton(title: "Add Field")
        addFieldButton.isEnabled = true
        addArrangedSubview(titleView)
        for view in fieldViews {
            addArrangedSubview(view)
        }
        addArrangedSubview(addFieldButton)
        self.axis = axis
        spacing = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addFieldView() {
        let fieldView = FieldStackView(fieldName: "Field \(fieldViews.count + 1) Name")
        insertArrangedSubview(fieldView, at: arrangedSubviews.endIndex - 1)
    }
}
