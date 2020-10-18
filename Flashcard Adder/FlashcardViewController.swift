//
//  FlashcardViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/15/20.
//

import UIKit
import MobileCoreServices
import os.log

class FlashcardViewController: UIViewController {
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
    @IBOutlet var referenceSpaceTextView: EditFieldTextView! {
        didSet {
            referenceSpaceTextView.text = flashcard.surroundingText
        }
    }
    @IBOutlet var resetButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var clozeButton: BigButton!
    @IBOutlet var deckButton: BigButton! {
        didSet {
            deckButton.setTitle("Deck: " + flashcard.deckName, for: .normal)
        }
    }

    @IBOutlet var typeButton: BigButton! {
        didSet {
            typeButton.setTitle("Type: " + flashcard.noteTypeName, for: .normal)
        }
    }

    var flashcard = Flashcard()
    var savedRange: UITextRange?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        #if Main
        navigationItem.leftBarButtonItems = [resetButton]
        #elseif Action
        navigationItem.leftBarButtonItems = [cancelButton, resetButton]
        #endif
        hideKeyboardWhenTappedAround()
        frontTextView.delegate = self
        backTextView.delegate = self
        flashcard.delegate = self
        
        updateAddButtonState()
        
        #if Action
        // By default on iPad, the action extension modal popup is insanely small. This resizes it to be like "Save to Files" and some other extensions
        // https://developer.apple.com/forums/thread/15674
        preferredContentSize = CGSize(width: 540, height: 620)
        let textItem = extensionContext!.inputItems[0] as! NSExtensionItem
        
        let textItemProvider = textItem.attachments![0]
        
        if textItemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            textItemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { result, _ in
                if let result = result as? String {
                    DispatchQueue.main.async {
                        self.frontTextView.text = result
                        self.flashcard.note.fields[0].text = result
                        self.referenceSpaceTextView.text = result
                    }
                }
            }
        }
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        enableCustomMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    @objc func willEnterForeground() {}
    
    // MARK: Keyboard/Menu Modifiers

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Create Cloze", action: #selector(clozeSelected), input: "c", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: "Editable Cloze", action: #selector(clozeWithHint), input: "v", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: "Cloze Back Text with Editable Hint", action: #selector(makeHintCloze), input: "f", modifierFlags: [.command, .shift] ),
            UIKeyCommand(title: "Sequential Cloze", action: #selector(sequentialCloze), input: "e", modifierFlags: [.command]),
            UIKeyCommand(title: "Repetitive Cloze", action: #selector(repetitiveCloze), input: "s", modifierFlags: [.command]),
            UIKeyCommand(title: "Editable Cloze", action: #selector(clozeWithHint), input: "d", modifierFlags: [.command]),
            UIKeyCommand(title: "Cloze Back Text with Editable Hint", action: #selector(makeHintCloze), input: "w", modifierFlags: [.command]),
            UIKeyCommand(title: "Add Note", action: #selector(addCard), input: "\r", modifierFlags: []),
            UIKeyCommand(title: "New Line", action: #selector(newLine), input: "\r", modifierFlags: [.shift])
        ]
    }
    
    func enableCustomMenu() {
        let sequential = UIMenuItem(title: "Sequential", action: #selector(sequentialCloze))
        let repetitive = UIMenuItem(title: "Repetitive", action: #selector(repetitiveCloze))
        let edit = UIMenuItem(title: "Edit", action: #selector(clozeWithHint))
        let hint = UIMenuItem(title: "Hint", action: #selector(makeHintCloze))
        
        UIMenuController.shared.menuItems = [sequential, repetitive, edit, hint]
    }
    
    // MARK: - Actions
    
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
    
    @IBAction func addCard(_ sender: Any) {
        guard let ankiUrl = flashcard.ankiUrl else {
            let alert = UIAlertController(title: "Incomplete Flashcard", message: "The currently filled out text does not create a flashcard", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        #if Main
        if UIApplication.shared.canOpenURL(ankiUrl) {
            clearFields()
            UIApplication.shared.open(ankiUrl, options: [:])
        } else {
            let alert = UIAlertController(title: "AnkiMobile Not Installed", message: "AnkiMobile Flashcards must be installed to add facts", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        #elseif Action
        
        // Inspired by Slide for Reddit https://github.com/ccrama/Slide-iOS/blob/develop/Open%20in%20Slide/ActionViewController.swift
        // And help from https://stackoverflow.com/a/40675306/14362235
        // Not sure how the cancelRequest dismisses it, but it does so we're good
        if self.openURL(ankiUrl) {
            self.extensionContext!.cancelRequest(withError: NSError(domain: "com.technaplex.Flashcard-Adder.Action-Extension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Action Extension Dismissed"]))
        } else {
            self.extensionContext!.cancelRequest(withError: NSError(domain: "com.technaplex.Flashcard-Adder.Action-Extension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Action Extension Dismissed"]))
        }
        #endif
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: Any) {
        #if Action
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        #endif
    }
    
    @IBSegueAction
    private func showNoteTypeList(coder: NSCoder, sender: Any?, segueIdentifier: String?)
        -> NoteTypeViewController? {
        Logger.flashcard.info("Showing Note Type List")
        return NoteTypeViewController(coder: coder, viewModel: NoteTypeViewModel(selected: flashcard.note))
    }
    
    @IBSegueAction
    private func showDeckList(coder: NSCoder, sender: Any?, segueIdentifier: String?)
        -> DeckViewController? {
        Logger.flashcard.info("Showing Deck List")
        return DeckViewController(coder: coder, viewModel: DeckViewModel(selected: flashcard.deck))
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
//        view.endEditing(true)
        switch segue.identifier ?? "" {
        case "deckTypeAnki":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let _ = navViewController.viewControllers.first as? SelectDeckTypeTableViewController else {
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
            resultViewController.referenceSpaceText = flashcard.surroundingText
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
            
            resultViewController.referenceSpaceText = flashcard.surroundingText
        default:
            Logger.segue.fault("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
 
    @IBAction func unwindToFlashcardView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SelectDeckTypeTableViewController {
            flashcard.updateDeck(to: sourceViewController.deck)
            
            /*
             deckButton.setTitle("Deck: " + deck, for: .normal)
             ankiSettings[2] = deck
             */
        } else if let sourceViewController = sender.source as? ClozeViewController {
            createCloze(clozeText: sourceViewController.clozeTextView.text, hintText: sourceViewController.hintTextView.text)
        } else if let sourceViewController = sender.source as? NoteTypeViewController {
            flashcard.updateNoteType(to: sourceViewController.viewModel.selectedNote)
        } else if let sourceViewController = sender.source as? DeckViewController {
            flashcard.updateDeck(to: sourceViewController.viewModel.selectedDeck)
        }
    }
    
    //MARK: Action Extension
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        self.extensionContext!.cancelRequest(withError: NSError(domain: "com.technaplex.Flashcard-Adder.Action-Extension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Action Extension Dismissed"]))
//        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
//        self.extensionContext!.cancelRequest(withError: NSError()) // Maybe don't 'cancel request'
        return false
    }
}

// MARK: Cloze
extension FlashcardViewController {
    @IBAction func clozeSelected(_ sender: Any) {
        determineCloze(sequential: true) // TODO: Update to use 'default', bring up a menu for alternative
    }
    
    @objc func repetitiveCloze(_ sender: Any) {
        determineCloze(sequential: false)
    }
    
    @objc func sequentialCloze(_ sender: Any) {
        determineCloze(sequential: true)
    }
    
    // Maybe put this in Field instead, with Flashcard as a delegate
    func determineCloze(sequential: Bool) {
        let clozeCounter: Int
        if sequential {
            clozeCounter = (Cloze.highestCurrentCloze(text: frontTextView.text) ?? 0) + 1
        } else {
            clozeCounter = Cloze.highestCurrentCloze(text: frontTextView.text) ?? 1
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
        let clozeCounter = (Cloze.highestCurrentCloze(text: frontTextView.text) ?? 0) + 1
        let cloze = Cloze(subject: clozeText, hint: hintText).clozeString(with: clozeCounter)
        
        if let textRange = savedRange {
            frontTextView.replace(textRange, withText: cloze)
        }
        
        flashcard.updateNoteType(to: FlashcardSettings.shared.defaultClozeNoteType)
        // TODO: Handle frontLabel, backLabel, typeButton updates (or more fields)
    }
    
    func clozeCount() -> Int {
        frontTextView.text.count
    }
    
    @objc func clozeWithHint(_ sender: Any) {
        performSegue(withIdentifier: "editableCloze", sender: sender)
    }
    
    @objc func makeHintCloze(sender: UIMenuController) {
        performSegue(withIdentifier: "clozeBackText", sender: sender)
    }
}

// MARK: UITextViewDelegate
extension FlashcardViewController: UITextViewDelegate {
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
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == frontTextView {
            flashcard.updateField(with: frontLabel.text ?? "", to: frontTextView.text)
        } else if textView == backTextView {
            flashcard.updateField(with: backLabel.text ?? "", to: backTextView.text)
        }
        
        updateAddButtonState()
    }
    
    func updateAddButtonState() {
        if flashcard.isValid {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
    }
}

// MARK: FlashcardDelegate
extension FlashcardViewController: FlashcardDelegate {
    func noteTypeDidChange(flashcard: Flashcard, from: Note, to: Note) {
        typeButton.setTitle("Type: " + flashcard.noteTypeName, for: .normal)
    }
    
    func deckDidChange(flashcard: Flashcard, from: Deck, to: Deck) {
        deckButton.setTitle("Deck: " + flashcard.deckName, for: .normal)
    }
    
    func flashcardAddDidFail(flashcard: Flashcard) {
        Logger.flashcard.error("Flashcard add failed")
    }
    
    func flashcardAddDidSucceed(flashcard: Flashcard) {
        Logger.flashcard.info("Flashcard add succeeded")
    }
    

}
