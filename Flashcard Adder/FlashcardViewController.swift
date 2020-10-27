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
            referenceSpaceTextView.text = flashcard.referenceText
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
    @IBOutlet weak var profileButton: BigButton! {
        didSet {
            profileButton.setTitle("Profile: " + flashcard.profileName, for: .normal)
        }
    }
    
    var flashcard = Flashcard()
    
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
        referenceSpaceTextView.delegate = self
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
    
    @IBAction func reset(_ sender: Any) {
        hardReset()
    }
    
    // Resets fields while preserving decks/etc with a new flashcard
    @objc func softReset() {
        flashcard = Flashcard(previous: flashcard, delegate: self)
    }
    
    // Resets to default settings with a new flashcard
    @objc func hardReset() {
        flashcard = Flashcard(delegate: self)
    }
    /// Adds a new line to the currently active text view, if a text view is active
    @objc func newLine() {
        if let firstResponder = view.window?.firstResponder as? UITextView {
            firstResponder.text = firstResponder.text + "\n"
        }
    }
    
    @IBAction func addCard(_ sender: Any) {
        guard let ankiUrl = flashcard.getAnkiUrl() else {
            let alert = UIAlertController(title: "Incomplete Flashcard", message: "The currently filled out text does not create a flashcard", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        #if Main
        if UIApplication.shared.canOpenURL(ankiUrl) {
            softReset()
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
    
    @IBAction func changeProfile(_ sender: Any) {
        let profileViewController = OptionViewController(viewModel: ProfileViewModel(selected: flashcard.profile, controllerDelegate: self))
        let navigationController = UINavigationController(rootViewController: profileViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    @IBAction func changeDeck(_ sender: Any) {
        let profileViewController = OptionViewController(viewModel: DeckViewModel(selected: flashcard.deck, controllerDelegate: self))
        let navigationController = UINavigationController(rootViewController: profileViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBSegueAction
    private func showNoteTypeList(coder: NSCoder, sender: Any?, segueIdentifier: String?)
        -> NoteTypeViewController? {
        Logger.flashcard.info("Showing Note Type List")
        return NoteTypeViewController(coder: coder, viewModel: NoteTypeViewModel(selected: flashcard.note))
    }
    
    /*
    @IBSegueAction
    private func showDeckList(coder: NSCoder, sender: Any?, segueIdentifier: String?)
        -> DeckViewController? {
        Logger.flashcard.info("Showing Deck List")
        return DeckViewController(coder: coder, viewModel: DeckViewModel(selected: flashcard.deck))
    }
    */
    
    @IBSegueAction
    private func showClozeView(coder: NSCoder, sender: Any?, segueIdentifier: String?)
        -> ClozeViewController? {
        var viewModel: ClozeViewModel!
        
        switch segueIdentifier {
        case FlashcardSettings.Segues.goToClozeWithEdit:
            if let textRange = frontTextView.selectedTextRange {
                viewModel = ClozeViewModel(cloze: frontTextView.text(in: textRange)?.trimmingCharacters(in: .whitespacesAndNewlines), referenceSpaceText: flashcard.referenceText, savedRange: textRange, beginWithHint: true)
            } else {
                viewModel = ClozeViewModel(referenceSpaceText: flashcard.referenceText, beginWithHint: true)
            }
            Logger.flashcard.info("Showing Cloze View with Editable Selection")
        case FlashcardSettings.Segues.goToClozeWithBackText:
            if let textRange = frontTextView.selectedTextRange {
                viewModel = ClozeViewModel(cloze: backTextView.text.trimmingCharacters(in: .whitespacesAndNewlines), hint: frontTextView.text(in: textRange)?.trimmingCharacters(in: .whitespacesAndNewlines), referenceSpaceText: flashcard.referenceText, savedRange: textRange, beginWithHint: false)
            } else {
                viewModel = ClozeViewModel(referenceSpaceText: flashcard.referenceText, beginWithHint: false)
            }
            Logger.flashcard.info("Showing Cloze View with Back Text")
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segueIdentifier))")
        }
        
        
        return ClozeViewController(coder: coder, viewModel: viewModel)
    }
    
    @IBAction func unwindToFlashcardView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ClozeViewController {
            createCloze(clozeText: sourceViewController.viewModel.cloze, hintText: sourceViewController.viewModel.hint, savedRange: sourceViewController.viewModel.savedRange)
        } else if let sourceViewController = sender.source as? NoteTypeViewController {
            flashcard.updateNoteType(to: sourceViewController.viewModel.selectedNote)
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
    }
    
    func createCloze(clozeText: String, hintText: String, savedRange: UITextRange?) {
        let clozeCounter = (Cloze.highestCurrentCloze(text: frontTextView.text) ?? 0) + 1
        let cloze = Cloze(subject: clozeText, hint: hintText).clozeString(with: clozeCounter)
        
        if let textRange = savedRange {
            frontTextView.replace(textRange, withText: cloze)
        }
        
        flashcard.updateNoteType(to: FlashcardSettings.shared.defaultClozeNoteType)
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
        if textView == frontTextView || textView == backTextView || textView == referenceSpaceTextView, text == "\t" || text == "\n" {
            if text == "\t" {
                if textView == frontTextView {
                    backTextView.becomeFirstResponder()
                }
                
                if textView == backTextView {
                    referenceSpaceTextView.becomeFirstResponder()
                }
                
                if textView == referenceSpaceTextView {
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
            flashcard.updateField(name: frontLabel.text ?? "", to: frontTextView.text)
        } else if textView == backTextView {
            flashcard.updateField(name: backLabel.text ?? "", to: backTextView.text)
        } else if textView == referenceSpaceTextView {
            flashcard.referenceText = referenceSpaceTextView.text
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
    func profileDidChange(flashcard: Flashcard, from: Profile, to: Profile) {
        profileButton.setTitle("Profile: " + flashcard.profileName, for: .normal)
    }
    
    func noteTypeDidChange(flashcard: Flashcard, from: Note, to: Note) {
        typeButton.setTitle("Type: " + flashcard.noteTypeName, for: .normal)
        frontLabel.text = to.fields[0].name
        backLabel.text = to.fields[1].name
    }
    
    func deckDidChange(flashcard: Flashcard, from: Deck, to: Deck) {
        deckButton.setTitle("Deck: " + flashcard.deckName, for: .normal)
    }
    
    func flashcardDidCreate(flashcard: Flashcard) {
        frontTextView.text = flashcard.note.fields[0].text
        backTextView.text = flashcard.note.fields[1].text
        typeButton.setTitle("Type: " + flashcard.noteTypeName, for: .normal)
        deckButton.setTitle("Deck: " + flashcard.deckName, for: .normal)
    }
}

// MARK: FlashcardDelegate
extension FlashcardViewController: DeckViewControllerDelegate {
    func deckSelected(_ deck: Deck) {
        flashcard.updateDeck(to: deck)
    }
}

extension FlashcardViewController: OptionViewControllerDelegate {
    func profileChanged(_ profile: Profile) {
        flashcard.updateProfile(to: profile)
    }
    func deckChanged(_ deck: Deck) {
        flashcard.updateDeck(to: deck)
    }
}
