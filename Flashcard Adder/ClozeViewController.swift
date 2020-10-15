//
//  ClozeViewController.swift
//  iQuiz
//
//  Created by Matthew on 4/8/19.
//  Copyright © 2019 Innoviox. All rights reserved.
//

import UIKit

class ClozeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var clozeTextView: EditFieldTextView!
    @IBOutlet weak var hintTextView: EditFieldTextView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    //    @IBOutlet weak var clozeText: EditFieldTextView!
    //    @IBOutlet weak var hintText: EditFieldTextView!
    //    @IBOutlet weak var addButton: UIBarButtonItem!
    var cloze = ""
    var hint = ""
    var surroundingText = ""
    
//    @IBOutlet weak var surroundingTextView: UITextView!
    var beginWithHint = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        clozeTextView.text = cloze.trimmingCharacters(in: .whitespacesAndNewlines)
        hintTextView.text = hint.trimmingCharacters(in: .whitespacesAndNewlines)
        
//        surroundingTextView.text = surroundingText
        
        self.clozeTextView.delegate = self
        self.hintTextView.delegate = self
        
        if self.beginWithHint {
            self.hintTextView.becomeFirstResponder()
        } else {
            self.clozeTextView.becomeFirstResponder()
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(addCloze), discoverabilityTitle: "Add Cloze")
        ]
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addThe(_ sender: Any) {
        print(clozeTextView.text.prefix(1) == " ")
        if clozeTextView.text.prefix(1) == " " {
            clozeTextView.text = "The\(clozeTextView.text!)"
        } else {
            clozeTextView.text = "The \(clozeTextView.text!)"
        }
        
    }
    
    @IBAction func addPossession(_ sender: Any) {
        if clozeTextView.text.suffix(1) == " " {
            clozeTextView.text = "\(clozeTextView.text!.dropLast(1))'s"
        } else {
            clozeTextView.text = "\(clozeTextView.text!)'s"
        }
    }
    
    @objc func addCloze() {
        performSegue(withIdentifier: "unwindToAnkiFromCloze", sender: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateAddButtonState()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        updateAddButtonState()
    }
    func textViewDidChange(_ textView: UITextView) {
        updateAddButtonState()
    }
    
    func updateAddButtonState() {
        let text = clozeTextView.text ?? ""
        addButton.isEnabled = !text.isEmpty
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
        if (text == "\t" || text == "\n") && (textView == clozeTextView || textView == hintTextView) {
            if text == "\t" {
                if textView == clozeTextView {
                    hintTextView.becomeFirstResponder()
                }
                
                if textView == hintTextView {
                    clozeTextView.becomeFirstResponder()
                }
            } else if text == "\n" {
                performSegue(withIdentifier: "unwindToAnkiFromCloze", sender: true)
            }
            
            return false
        } else {
            return true
        }
    }
}
