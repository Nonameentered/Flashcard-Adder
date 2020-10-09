//
//  AnkiViewController.swift
//  iQuiz
//
//  Created by Matthew on 12/24/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

class AnkiViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var frontLabel: UILabel! {
        didSet {
            frontLabel.text = flashcard.fieldNames[0]
        }
    }

    @IBOutlet var frontTextView: EditFieldTextView! {
        didSet {
            frontTextView.text = flashcard.originalText
        }
    }
    
    @IBOutlet var backLabel: UILabel! {
        didSet {
            backLabel.text = flashcard.fieldNames[1]
        }
    }

    @IBOutlet var backTextView: EditFieldTextView!
//    @IBOutlet var tagsLabel: UILabel!
//    @IBOutlet var tagsTextView: EditFieldTextView!
//    @IBOutlet var surroundingTextLabel: UILabel!
//    @IBOutlet var surroundingTextView: UITextView! {
//        didSet {
//            surroundingTextView.text = flashcard.surroundingText
//        }
//    }
    
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var resetButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    @IBOutlet var clozeButton: BigButton!
    @IBOutlet var deckButton: BigButton! {
        didSet {
            deckButton.setTitle("Deck: " + flashcard.deckName, for: .normal)
        }
    }

    @IBOutlet var typeButton: BigButton! {
        didSet {
            typeButton.setTitle("Type: " + flashcard.typeName, for: .normal)
        }
    }
    
    var flashcard = Flashcard()
    var savedRange: UITextRange?
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Maybe unnecessary
        flashcard = Flashcard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.navigationItem.leftBarButtonItems = [resetButton]
        hideKeyboardWhenTappedAround()
        frontTextView.delegate = self
        backTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        enableCustomMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    @objc func willEnterForeground() {
        
    }
    
    // MARK: Keyboard/Menu Modifiers
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "c", modifierFlags: [.command, .shift], action: #selector(clozeSelected), discoverabilityTitle: "Cloze"),
            UIKeyCommand(input: "v", modifierFlags: [.command, .shift], action: #selector(clozeWithHint), discoverabilityTitle: "Editable Cloze"),
            UIKeyCommand(input: "f", modifierFlags: [.command, .shift], action: #selector(makeHintCloze), discoverabilityTitle: "Cloze Back Text with Editable Hint"),
            UIKeyCommand(input: "e", modifierFlags: [.command], action: #selector(sequentialCloze), discoverabilityTitle: "Sequential Cloze"),
            UIKeyCommand(input: "s", modifierFlags: [.command], action: #selector(repetitiveCloze), discoverabilityTitle: "Repetitive Cloze"),
            UIKeyCommand(input: "d", modifierFlags: [.command], action: #selector(clozeWithHint), discoverabilityTitle: "Editable Cloze"),
            UIKeyCommand(input: "w", modifierFlags: [.command], action: #selector(makeHintCloze), discoverabilityTitle: "Cloze Back Text with Editable Hint"),
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(addCard), discoverabilityTitle: "Add Note"),
            UIKeyCommand(input: "\r", modifierFlags: [.shift], action: #selector(newLine), discoverabilityTitle: "New Line")
        ]
    }
    
    func enableCustomMenu() {
        // let makeHint = UIMenuItem(title: "Make Hint", action: #selector(self.makeHintCloze(sender:)))
        // UIMenuController.shared.menuItems = [makeHint]
    }
    
    // MARK: Cloze
    
    @IBAction func clozeSelected(_ sender: Any) {
        determineCloze(sequential: true) // TODO: Update to use 'default'
    }
    
    @objc func repetitiveCloze(_ sender: Any) {
        determineCloze(sequential: false)
    }
    
    @objc func sequentialCloze(_ sender: Any) {
        determineCloze(sequential: true)
    }
    
    func determineCloze(sequential: Bool) {
        let clozeCounter: Int
        if sequential {
            clozeCounter = frontTextView.text.countInstances(of: "{{c") + 1
        } else {
            clozeCounter = frontTextView.text.countInstances(of: "{{c")
        }
        
        
        if let textRange = frontTextView.selectedTextRange {
            let subject = frontTextView.text(in: textRange)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            let clozeString = Cloze(subject: subject).clozeString(with: clozeCounter)
            
            frontTextView.replace(textRange, withText: clozeString)
        }
        
        flashcard.updateNoteType(to: FlashcardSettings.shared.defaultClozeNoteType)
        // TODO: Handle frontLabel, backLabel, typeButton updates (or more fields)
    }
    
    func createCloze(clozeText: String, hintText: String) {
        let clozeCounter = frontTextView.text.countInstances(of: "{{c") + 1
        let cloze = Cloze(subject: clozeText, hint: hintText).clozeString(with: clozeCounter)
        
        if let textRange = savedRange {
            frontTextView.replace(textRange, withText: cloze)
        }
        
        flashcard.updateNoteType(to: FlashcardSettings.shared.defaultClozeNoteType)
        // TODO: Handle frontLabel, backLabel, typeButton updates (or more fields)
    }
    
    @objc func clozeWithHint(_ sender: Any) {
        performSegue(withIdentifier: "editableCloze", sender: sender)
    }
    
    @objc func makeHintCloze(sender: UIMenuController) {
        performSegue(withIdentifier: "clozeBackText", sender: sender)
    }
    
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Adds a new line to the currently active text view, if a text view is active
    @objc func newLine() {
        if let firstResponder = view.window?.firstResponder as? UITextView {
            firstResponder.text = firstResponder.text + "\n"
        }
    }
    
    func clearFields() {
        frontTextView.text = ""
        backTextView.text = ""
    }
    
    func setFlashcardText() {
        flashcard.updateField(with: frontLabel.text ?? "", to: frontTextView.text)
        flashcard.updateField(with: backLabel.text ?? "", to: backTextView.text)
    }
    
    // MARK: - Navigation
    
    @IBAction func addCard(_ sender: Any) {
        // Enable add button only when fields are not empty
        setFlashcardText()
        guard let ankiUrl = flashcard.ankiUrl else {
            return
        }
        
        if UIApplication.shared.canOpenURL(ankiUrl) {
            clearFields()
            UIApplication.shared.open(ankiUrl, options: [:])
        } else {
            let alert = UIAlertController(title: "AnkiMobile Not Installed", message: "AnkiMobile Flashcards must be installed to add facts", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
//        view.endEditing(true)
        switch segue.identifier ?? "" {
        case "noteTypeAnki":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let resultViewController = navViewController.viewControllers.first as? SelectNoteTypeTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
        case "deckTypeAnki":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let resultViewController = navViewController.viewControllers.first as? SelectDeckTypeTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
        case "editableCloze":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let resultViewController = navViewController.viewControllers.first as? ClozeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if let textRange = frontTextView.selectedTextRange {
                let clozeText = frontTextView.text(in: textRange) ?? ""
                resultViewController.cloze = clozeText
                resultViewController.hint = ""
                savedRange = textRange
            }
            resultViewController.surroundingText = flashcard.surroundingText
            resultViewController.beginWithHint = true
        case "clozeBackText":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let resultViewController = navViewController.viewControllers.first as? ClozeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if let textRange = frontTextView.selectedTextRange {
                let hintText = frontTextView.text(in: textRange) ?? ""
                resultViewController.cloze = backTextView!.text
                resultViewController.hint = hintText
                savedRange = textRange
            }
            
            resultViewController.surroundingText = flashcard.surroundingText
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
 
    @IBAction func unwindToAnkiView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SelectNoteTypeTableViewController {
            flashcard.updateNoteType(to: sourceViewController.noteType)
            /*
             type = sourceViewController.selectedNoteType
             fields = noteTypes[String(sourceViewController.selectedNoteType)] ?? ["Front", "Back"]
             frontLabel.text = fields[0]
             backLabel.text = fields[1]
            
             typeButton.setTitle("Type: " + type, for: .normal)
             ankiSettings[1] = type
             */
        } else if let sourceViewController = sender.source as? SelectDeckTypeTableViewController {
            flashcard.updateDeck(to: sourceViewController.deck)
            
            /*
             deckButton.setTitle("Deck: " + deck, for: .normal)
             ankiSettings[2] = deck
             */
        } else if let sourceViewController = sender.source as? ClozeViewController {
            createCloze(clozeText: sourceViewController.clozeTextView.text, hintText: sourceViewController.hintTextView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == frontTextView || textView == backTextView, text == "\t" {
            if text == "\t" {
                if textView == frontTextView {
                    backTextView.becomeFirstResponder()
                }
                
                if textView == backTextView {
                    frontTextView.becomeFirstResponder()
                }
            }
            
            return false
        } else {
            return true
        }
    }
}
