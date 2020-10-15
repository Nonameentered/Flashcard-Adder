//
//  AddNoteViewController.swift
//  iQuiz
//
//  Created by Matthew on 12/26/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var noteNameField: EditFieldTextView!
    @IBOutlet weak var firstNameField: EditFieldTextView!
    @IBOutlet weak var secondNameField: EditFieldTextView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteNameField.delegate = self
        firstNameField.delegate = self
        secondNameField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    func textViewDidBeginEditing(_ textView: UITextView) {
        updateAddButtonState()
    }
    */
    func textViewDidChange(_ textView: UITextView) {
        updateAddButtonState()
    }
    
    func updateAddButtonState() {
        let noteText = noteNameField.text ?? ""
        let field1Text = firstNameField.text ?? ""
        let field2Text = secondNameField.text ?? ""
        addButton.isEnabled = !noteText.isEmpty && !field1Text.isEmpty && !field2Text.isEmpty
    }
}
