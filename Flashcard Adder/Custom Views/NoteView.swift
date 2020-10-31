//
//  NoteView.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/31/20.
//

import UIKit

protocol NoteViewDelegate {
    func noteUpdated()
}

class NoteView: UIStackView {
    private var titleView: FieldStackView!
    private var fieldViews: [FieldStackView]! {
        didSet {
            removeFieldButton.isEnabled = fieldViews.count > 2
        }
    }

    private lazy var addFieldButton = UIButton.createStandardButton(withTitle: "Add Field")
    private lazy var removeFieldButton = UIButton.createStandardButton(withTitle: "Remove Field")
    private lazy var clozeSwitch = UISwitch(frame: .zero, primaryAction: UIAction { _ in
        self.isCloze = !self.isCloze
    })
    private var clozeLabel: UILabel!
    private var fields: [Field] {
        fieldViews.enumerated().map { (index, element) -> Field in
            Field(name: element.textView.text, fieldType: isCloze && index == 0 ? .cloze : .normal)
        }
    }

    private var isCloze: Bool! {
        didSet {
            clozeSwitch.isOn = isCloze
            titleView.titleLabel.text = "\(isCloze ? "Cloze " : "")Note Name"
        }
    }

    var note: Note? {
        if !titleView.textView.text.isEmpty, fields.filter({ $0.name.isEmpty }).isEmpty {
            return Note(name: titleView.textView.text, fields: fields)
        } else {
            return nil
        }
    }

    var delegate: NoteViewDelegate?
    
    init(initialNote: Note? = nil, axis: NSLayoutConstraint.Axis = .vertical) {
        super.init(frame: .zero)
        setUpView(initialNote: initialNote, axis: axis)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView(initialNote: Note?, axis: NSLayoutConstraint.Axis) {
        translatesAutoresizingMaskIntoConstraints = false
        self.axis = axis
        spacing = 10
        addFieldButton.addTarget(self, action: #selector(addFieldSelected), for: .touchUpInside)
        removeFieldButton.addTarget(self, action: #selector(removeFieldSelected), for: .touchUpInside)
        let buttonStackView = UIStackView(arrangedSubviews: [addFieldButton, removeFieldButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        
        addArrangedSubview(buttonStackView)
        if let initialNote = initialNote {
            titleView = FieldStackView(fieldName: "Note Name", text: initialNote.name)
            isCloze = initialNote.acceptsCloze
            fieldViews = initialNote.fields.enumerated().map { (index, element) -> FieldStackView in
                return FieldStackView(fieldName: "Field \(index + 1) Name", text: element.name)
            }
            
        } else {
            titleView = FieldStackView(fieldName: "Note Name")
            isCloze = false
            clozeLabel = UILabel()
            clozeLabel.text = "Accepts Cloze"
            let clozeView = UIStackView(arrangedSubviews: [clozeLabel, clozeSwitch])
            clozeView.axis = .horizontal
            clozeView.distribution = .fillEqually
            clozeView.spacing = 10
            addArrangedSubview(clozeView)
            fieldViews = [FieldStackView(fieldName: "Field 1 Name"), FieldStackView(fieldName: "Field 2 Name")]
        }
        addArrangedSubview(titleView)
        
        titleView.textView.delegate = self
        for view in fieldViews {
            view.textView.delegate = self
            addArrangedSubview(view)
        }
        titleView.textView.becomeFirstResponder()
    }
    
    private func addFieldView() {
        let fieldView = FieldStackView(fieldName: "Field \(fieldViews.count + 1) Name")
        fieldView.textView.delegate = self
        fieldViews.append(fieldView)
        addArrangedSubview(fieldView) // Could probably be done in property observer
        fieldView.textView.becomeFirstResponder()
    }
    
    @objc func addFieldSelected() {
        addFieldView()
    }
    
    @objc func removeFieldSelected() {
        if fieldViews.count > 2 {
            if let lastView = fieldViews.last {
                if lastView.textView.isFirstResponder {
                    fieldViews.removeLast()
                    fieldViews.last?.textView.becomeFirstResponder()
                }
                lastView.removeFromSuperview()
            }
        }
    }
    
    @objc func clozeButtonSelected() {
        isCloze = !isCloze
    }
}

extension NoteView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.noteUpdated()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\t" || text == "\n" {
            if text == "\t" {
                if let textView = textView as? EditTextView {
                    if textView == titleView.textView {
                        fieldViews[0].textView.becomeFirstResponder()
                    } else {
                        let index = (fieldViews.firstIndex(where: { $0.textView == textView }) ?? 0) + 1
                        if index >= fieldViews.count {
                            titleView.textView.becomeFirstResponder()
                        } else {
                            fieldViews[index].textView.becomeFirstResponder()
                        }
                    }
                }
            }
            return false
        } else {
            return true
        }
    }
}
