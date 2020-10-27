//
//  AddNoteViewController.swift
//  Flashcard Adder
//
//  Created by Matthew on 12/26/18.
//

import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var noteNameField: EditFieldTextView!
    @IBOutlet var firstNameField: EditFieldTextView!
    @IBOutlet var secondNameField: EditFieldTextView!
    @IBOutlet var addButton: UIBarButtonItem!
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteNameField.delegate = self
        firstNameField.delegate = self
        secondNameField.delegate = self
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateAddButtonState()
    }
    
    func updateAddButtonState() {
        let noteText = noteNameField.text ?? ""
        let field1Text = firstNameField.text ?? ""
        let field2Text = secondNameField.text ?? ""
        addButton.isEnabled = !noteText.isEmpty && !field1Text.isEmpty && !field2Text.isEmpty
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        if let noteName = noteNameField.text, let field1Name = firstNameField.text, let field2Name = secondNameField.text {
            note = Note(name: noteName, fields: [Field(name: field1Name), Field(name: field2Name)])
            performSegue(withIdentifier: FlashcardSettings.Segues.unwindToSelectNote, sender: self)
        }
        // TODO: Else throw error
        // TODO: Add Keyboard shortcut to call addButtonPressed
    }
}
