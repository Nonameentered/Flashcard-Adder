//
//  AddDeckViewController.swift
//  iQuiz
//
//  Created by Matthew on 12/26/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

class AddDeckViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var deckNameField: EditFieldTextView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deckNameField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    /*
    func textViewShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }*/
    
    func updateAddButtonState() {
        let text = deckNameField.text ?? ""
        addButton.isEnabled = !text.isEmpty
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
