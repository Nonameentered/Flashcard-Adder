// EditFieldTextView
//  ClozeViewController.swift
//  iQuiz
//
//  Created by Matthew on 4/8/19.
//  Copyright © 2019 Innoviox. All rights reserved.
//

import UIKit

class ClozeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var clozeTextView: EditFieldTextView!
    @IBOutlet var hintTextView: EditFieldTextView!
    @IBOutlet var addButton: UIBarButtonItem!
    
    @IBOutlet var referenceSpaceTextView: EditFieldTextView!
    var viewModel: ClozeViewModel
    
    init?(coder: NSCoder, viewModel: ClozeViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        clozeTextView.delegate = self
        hintTextView.delegate = self
        
        clozeTextView.text = viewModel.cloze
        hintTextView.text = viewModel.hint
        referenceSpaceTextView.text = viewModel.referenceSpaceText
        if viewModel.beginWithHint {
            hintTextView.becomeFirstResponder()
        } else {
            clozeTextView.becomeFirstResponder()
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Add Cloze", image: nil, action: #selector(addCloze), input: "\r", modifierFlags: [])
        ]
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addThe(_ sender: Any) {
        guard let text = clozeTextView.text else {
            return
        }
        
        if text.prefix(1) == " " {
            clozeTextView.text = "The\(text)"
        } else {
            clozeTextView.text = "The \(text)"
        }
        updateState()
    }
    
    @IBAction func addPossession(_ sender: Any) {
        guard let text = clozeTextView.text else {
            return
        }
        
        if text.suffix(1) == " " {
            clozeTextView.text = "\(text.dropLast(1))'s"
        } else {
            clozeTextView.text = "\(text)'s"
        }
        updateState()
    }
    
    @objc func addCloze() {
        performSegue(withIdentifier: "unwindToFlashcardFromCloze", sender: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateState()
    }
    
    func updateState() {
        addButton.isEnabled = !clozeTextView.text.isEmpty
        viewModel.update(cloze: clozeTextView.text, hint: hintTextView.text, referenceSpaceText: referenceSpaceTextView.text)
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        if textView == clozeTextView {
            hintTextView.becomeFirstResponder()
        }
        
        if textView == hintTextView {
            clozeTextView.becomeFirstResponder()
        }
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\t" || text == "\n", textView == clozeTextView || textView == hintTextView {
            if text == "\t" {
                if textView == clozeTextView {
                    hintTextView.becomeFirstResponder()
                }
                
                if textView == hintTextView {
                    clozeTextView.becomeFirstResponder()
                }
            } else if text == "\n" {
                addCloze()
            }
            
            return false
        } else {
            return true
        }
    }
}
