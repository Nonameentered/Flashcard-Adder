//
//  FlashcardViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/15/20.
//

import MobileCoreServices
import os.log
import UIKit

class FlashcardViewController: UIViewController {
    @IBOutlet var referenceSpaceTextView: EditTextView! {
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

    @IBOutlet var profileButton: BigButton! {
        didSet {
            profileButton.setTitle("Profile: " + flashcard.profileName, for: .normal)
        }
    }

    @IBOutlet var stackView: UIStackView!
    @IBOutlet var referenceSpaceStackView: UIStackView!
    @IBOutlet var clozeStackView: UIStackView!
    
    var fieldViews: [FieldStackView] = [] {
        didSet {
            for view in fieldViews {
                view.textView.delegate = self
            }
        }
    }
    
    var fieldTextViews: [EditTextView] {
        fieldViews.map { $0.textView }
    }

    var frontTextView: EditTextView {
        fieldViews[0].textView
    }

    var backTextView: EditTextView {
        fieldViews[1].textView
    }

    var flashcard = Flashcard()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpFieldViews()
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        #if Main
        navigationItem.leftBarButtonItems = [resetButton]
        #elseif Action
        navigationItem.leftBarButtonItems = [cancelButton, resetButton]
        #endif
        hideKeyboardWhenTappedAround()
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
    
    @objc func didEnterForeground() {
        if let savedFlashcard = FlashcardSettings.shared.savedFlashcard {
            flashcard = savedFlashcard
            setUpFieldViews()
            FlashcardSettings.shared.savedFlashcard = nil
        }
    }
    
    @objc func willResignActive() {
        FlashcardSettings.shared.savedFlashcard = flashcard
    }
    
    // MARK: View Modifications
    
    func setUpFieldViews() {
        DispatchQueue.main.async {
            self.fieldViews.forEach { $0.removeFromSuperview() }
            self.fieldViews = self.flashcard.fields.map { FieldStackView(fieldName: $0.name, text: $0.text, oneLine: false, isFrozen: $0.isFrozen, delegate: self) }
            
            for (count, view) in self.fieldViews.enumerated() {
                if count == 0 {
                    self.stackView.insertArrangedSubview(view, at: 0)
                } else if count == 1 {
                    self.stackView.insertArrangedSubview(view, at: 2)
                } else {
                    self.stackView.insertArrangedSubview(view, at: self.stackView.arrangedSubviews.count - 2)
                }
            }
            self.referenceSpaceTextView.text = self.flashcard.referenceText
            self.updateAddButtonState()
            self.frontTextView.becomeFirstResponder()
        }
    }
    
    // MARK: Keyboard/Menu Modifiers

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(title: "Create Cloze", action: #selector(clozeSelected), input: "c", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: "Editable Cloze", action: #selector(clozeWithHint), input: "v", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: "Cloze Back Text", action: #selector(makeHintCloze), input: "f", modifierFlags: [.command, .shift]),
            UIKeyCommand(title: "Sequential Cloze", action: #selector(sequentialCloze), input: "e", modifierFlags: [.command]),
            UIKeyCommand(title: "Repetitive Cloze", action: #selector(repetitiveCloze), input: "s", modifierFlags: [.command]),
            UIKeyCommand(title: "Editable Cloze", action: #selector(clozeWithHint), input: "d", modifierFlags: [.command]),
            UIKeyCommand(title: "Cloze Back Text", action: #selector(makeHintCloze), input: "w", modifierFlags: [.command]),
            UIKeyCommand(title: "Add Note", action: #selector(addCard), input: "\r", modifierFlags: [.command])
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

    @IBAction func clearReferencePressed(_ sender: Any) {
        referenceSpaceTextView.text = ""
        updateFlashcardText(with: referenceSpaceTextView)
    }
    
    @IBAction func cleanUpFrontPressed(_ sender: Any) {
        cleanUp(textView: frontTextView)
    }

    @IBAction func cleanUpReferencePressed(_ sender: Any) {
        cleanUp(textView: referenceSpaceTextView)
    }
    
    func cleanUp(textView: UITextView) {
        textView.text = textView.text.cleanedOfNewLines
        updateFlashcardText(with: textView)
        textView.becomeFirstResponder()
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
        if openURL(ankiUrl) {
            extensionContext!.cancelRequest(withError: NSError(domain: "com.technaplex.Flashcard-Adder.Action-Extension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Action Extension Dismissed"]))
        } else {
            extensionContext!.cancelRequest(withError: NSError(domain: "com.technaplex.Flashcard-Adder.Action-Extension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Action Extension Dismissed"]))
        }
        #endif
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: Any) {
        #if Action
        extensionContext!.completeRequest(returningItems: extensionContext!.inputItems, completionHandler: nil)
        #endif
    }
    
    @IBAction func changeProfile(_ sender: Any) {
        let profileViewController = OptionViewController(viewModel: ProfileViewModel(selected: flashcard.profile, controllerDelegate: self))
        let navigationController = UINavigationController(rootViewController: profileViewController)
        present(navigationController, animated: true, completion: nil)
    }

    @IBAction func changeDeck(_ sender: Any) {
        let deckViewController = OptionViewController(viewModel: DeckViewModel(selected: flashcard.deck, controllerDelegate: self))
        let navigationController = UINavigationController(rootViewController: deckViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func changeType(_ sender: Any) {
        let noteViewController = OptionViewController(viewModel: NoteViewModel(selected: flashcard.note, controllerDelegate: self))
        let navigationController = UINavigationController(rootViewController: noteViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBSegueAction
    private func showClozeView(coder: NSCoder, sender: Any?, segueIdentifier: String?)
        -> ClozeViewController?
    {
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
        }
    }
    
    // MARK: Action Extension

    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        extensionContext!.cancelRequest(withError: NSError(domain: "com.technaplex.Flashcard-Adder.Action-Extension", code: 1, userInfo: [NSLocalizedDescriptionKey: "Action Extension Dismissed"]))
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
            
            cloze(textRange: textRange, clozeString: clozeString)
        }
    }
    
    func createCloze(clozeText: String, hintText: String, savedRange: UITextRange?) {
        let clozeCounter = (Cloze.highestCurrentCloze(text: frontTextView.text) ?? 0) + 1
        let clozeString = Cloze(subject: clozeText, hint: hintText).clozeString(with: clozeCounter)
        
        if let textRange = savedRange {
            cloze(textRange: textRange, clozeString: clozeString)
        }
    }
    
    func cloze(textRange: UITextRange, clozeString: String) {
        frontTextView.replace(textRange, withText: clozeString)
        if !flashcard.note.acceptsCloze {
            flashcard.updateNoteType(to: FlashcardSettings.shared.defaultClozeNoteType)
        }
        
        frontTextView.becomeFirstResponder()
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
        if text == "\t" {
            if let textView = textView as? EditTextView, let index = fieldViews.firstIndex(where: { $0.textView == textView }) {
                if let fieldView = fieldViews[safe: index + 1] {
                    fieldView.textView.becomeFirstResponder()
                } else {
                    referenceSpaceTextView.becomeFirstResponder()
                }
            }
            
            if textView == referenceSpaceTextView {
                fieldViews[0].textView.becomeFirstResponder()
            }
            return false
        } else {
            return true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateFlashcardText(with: textView)
    }
    
    func updateFlashcardText(with textView: UITextView) {
        if let textView = textView as? EditTextView, let fieldView = fieldViews.first(where: { $0.textView == textView }), let fieldName = fieldView.titleLabel.text {
            flashcard.updateField(name: fieldName, to: textView.text)
        }
        
        if textView == referenceSpaceTextView {
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
        setUpFieldViews()
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

extension FlashcardViewController: OptionViewControllerDelegate {
    func profileChanged(_ profile: Profile) {
        flashcard.updateProfile(to: profile)
    }

    func deckChanged(_ deck: Deck) {
        flashcard.updateDeck(to: deck)
    }
    
    func noteChanged(_ note: Note) {
        flashcard.updateNoteType(to: note)
    }
}

// MARK: FlashcardDelegate

extension FlashcardViewController: FieldStackViewDelegate {
    func didToggle(view: FieldStackView, starState: Bool) {
        if let name = view.titleLabel.text {
            flashcard.toggleFrozenField(name: name, to: starState)
        }
    }
}
