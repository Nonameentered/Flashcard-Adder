//
//  AnkiViewController.swift
//  iQuiz
//
//  Created by Matthew on 12/24/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

class AnkiViewController: UIViewController, UITextViewDelegate{
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var frontTextView: EditFieldTextView!
    
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var backTextView: EditFieldTextView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var tagsTextView: EditFieldTextView!
    @IBOutlet weak var surroundingTextLabel: UILabel!
    @IBOutlet weak var surroundingTextView: UITextView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var clozeButton: BigButton!
    @IBOutlet weak var deckButton: BigButton!
    @IBOutlet weak var typeButton: BigButton!
    
    var ankiSettings = UserDefaults.standard.object(forKey: "ankiDefaults") as? Array<String> ?? ["User 1", "Basic", "Default", "Front", "Back", ""]
    var profile:String = ""
    var type:String = ""
    var deck:String = ""
    var fields:Array<String> = []
    var selectedTags:String = ""
    var surroundingText = ""
    var theFrontText = ""
    var theBackText = ""
    var noteTypes: [String:[String]] = UserDefaults.standard.object(forKey: "ankiNoteOptions") as? [String:[String]] ?? ["Basic":["Front", "Back"], "Cloze":["Text", "Extra"]]
    
    var comesFrom = ""
    var inResults = false
    var savedRange:UITextRange?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        profile = ankiSettings[0]
        type = ankiSettings[1]
        deck = ankiSettings[2]
        fields = [ankiSettings[3], ankiSettings[4]]
        selectedTags = ankiSettings[5]
        surroundingTextView.text = surroundingText
        frontTextView.text = theFrontText
        backTextView.text = theBackText
        
        typeButton.setTitle("Type: " + type, for: .normal)
        deckButton.setTitle("Deck: " + deck, for: .normal)
        frontLabel.text = ankiSettings[3]
        backLabel.text = ankiSettings[4]
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
        self.frontTextView.delegate = self
        self.backTextView.delegate = self
        self.tagsTextView.delegate = self
        
        if comesFrom != "results" {
            surroundingTextLabel.isHidden = true
            surroundingTextView.isHidden = true
            self.navigationItem.leftBarButtonItem = nil
            placeSentTextInField()
        } else {
            surroundingTextLabel.isHidden = false
            surroundingTextView.isHidden = false
            inResults = true
            frontTextView.becomeFirstResponder()
        }
    }
    
    //use this if we ever need to update things when entering in foreground again
    @objc func willEnterForeground(){
        if comesFrom != "results" {
            placeSentTextInField()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        enableCustomMenu()
    }
    
    func enableCustomMenu() {
        //let makeHint = UIMenuItem(title: "Make Hint", action: #selector(self.makeHintCloze(sender:)))
        //UIMenuController.shared.menuItems = [ankiTossups, ankiBonuses, ankiQuickTossups, ankiQuickBonuses, searchTossups, searchAllTossups, searchBonuses, searchAllBonuses]
        //UIMenuController.shared.menuItems = [makeHint]
    }
    
    @objc func addNote() {
        
        if checkFilled() {
            addCard(self)
        }
    }
    
    @objc func newLine() {
        if let firstResponder = view.window?.firstResponder as? UITextView {
            
            firstResponder.text = firstResponder.text + "\n"
        }
    }
    
    func placeSentTextInField() {
        var addToAnkiString = ""
        if addToAnkiString == "" {
            frontTextView.becomeFirstResponder()
        } else if frontTextView.text == "" {
            frontTextView.text = addToAnkiString
            backTextView.becomeFirstResponder()
        } else {
            backTextView.text = addToAnkiString
            tagsTextView.becomeFirstResponder()
        }
        
        addToAnkiString = ""
    }
    
    func checkFilled() -> Bool {
        if frontTextView.text == "" {
            if backTextView.text == "" {
                if typeButton.currentTitle! == "Cloze" {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        } else {
            return true
        }
        
    }
    
    func clearFields() {
        frontTextView.text = ""
        backTextView.text = ""
        tagsTextView.text = ankiSettings[5] //ankiSettings[5] is default tags
    }
    
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "c", modifierFlags: [.command, .shift], action: #selector(clozeSelected), discoverabilityTitle: "Cloze"),
            UIKeyCommand(input: "v", modifierFlags: [.command, .shift], action: #selector(clozeWithHint), discoverabilityTitle: "Editable Cloze"),
            UIKeyCommand(input: "f", modifierFlags: [.command, .shift], action: #selector(makeHintCloze), discoverabilityTitle: "Cloze Back Text with Editable Hint"),
            UIKeyCommand(input: "e", modifierFlags: [.command], action: #selector(clozeSelected), discoverabilityTitle: "Sequential Cloze"),
            UIKeyCommand(input: "s", modifierFlags: [.command], action: #selector(repetitiveCloze), discoverabilityTitle: "Repetitive Cloze"),
            UIKeyCommand(input: "d", modifierFlags: [.command], action: #selector(clozeWithHint), discoverabilityTitle: "Editable Cloze"),
            UIKeyCommand(input: "w", modifierFlags: [.command], action: #selector(makeHintCloze), discoverabilityTitle: "Cloze Back Text with Editable Hint"),
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(addNote), discoverabilityTitle: "Add Note"),
            UIKeyCommand(input: "\r", modifierFlags: [.shift], action: #selector(newLine), discoverabilityTitle: "New Line")
        ]
    }
   
    @IBAction func clozeSelected(_ sender: Any) {
        determineCloze(sequential: true)
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
        
        var clozedText = ""
        let hintText = "::"
        var cloze = "{{c\(clozeCounter)::\(clozedText)\(hintText)}}"
        
        
        if let textRange = frontTextView.selectedTextRange {
            clozedText = frontTextView.text(in: textRange)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if hintText != "::" {
                cloze = "{{c\(clozeCounter)::\(clozedText)\(hintText)}}"
            } else {
                cloze = "{{c\(clozeCounter)::\(clozedText)}}"
            }
            
            frontTextView.replace(textRange, withText: cloze)
        }
        
        type = "Cloze"
        fields = ["Text", "Extra"]
        frontLabel.text = fields[0]
        backLabel.text = fields[1]
        
        typeButton.setTitle("Type: " + type, for: .normal)
        ankiSettings[1] = type
    }
    
    func createCloze(clozedText: String, hintText: String) {
        let clozeCounter = frontTextView.text.countInstances(of: "{{c") + 1
        let cloze = "{{c\(clozeCounter)::\(clozedText)::\(hintText)}}"
        
        if let textRange = savedRange {
            frontTextView.replace(textRange, withText: cloze)
        }
        
        type = "Cloze"
        fields = ["Text", "Extra"]
        frontLabel.text = fields[0]
        backLabel.text = fields[1]
        
        typeButton.setTitle("Type: " + type, for: .normal)
        ankiSettings[1] = type
    }
    
    
    @objc func clozeWithHint(_ sender: Any) {
        performSegue(withIdentifier: "editableCloze", sender: sender)
    }
    
    @objc func makeHintCloze(sender: UIMenuController) {
        performSegue(withIdentifier: "clozeBackText", sender: sender)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addCard(_ sender: Any) {
        if type == "Cloze" && frontTextView.text.countInstances(of: "{{c") == 0 {
            type = "Basic"
            typeButton.setTitle("Type: " + type, for: .normal)
            fields = noteTypes[type] ?? ["Front", "Back"]
        }
        
//        let xsuccess = "&x-success=quizdb://"
        let xsuccess = "&x-success=ankiadd://"
//        var ankiUrl = "anki://x-callback-url/addnote?profile=\(profile)&type=\(type)&deck=\(deck)"
        
        var ankiUrl = "anki://x-callback-url/addnote?profile=\(profile)&type=\(type)&deck=\(deck)"
        
        var count = 0
        for eachField in fields {
            if count == 0 {
                
                ankiUrl.append("&fld\(eachField)=\(frontTextView.text!)")
            } else if count == 1 {
                
                ankiUrl.append("&fld\(eachField)=\(backTextView.text!)")
            }
            count += 1
        }
        
        ankiUrl.append("&tags=\(selectedTags.trimmingCharacters(in: .whitespaces))")
        clearFields()
        ankiUrl.append(xsuccess)
        
        if let url = URL(string: ankiUrl.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                let alert = UIAlertController(title: "AnkiMobile Not Installed", message: "AnkiMobile Flashcards must be installed to add facts", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        self.view.endEditing(true)
        switch(segue.identifier ?? "") {
        case "noteTypeAnki":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let resultViewController = navViewController.viewControllers.first as? SelectNoteTypeTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            resultViewController.ankiSettings = ankiSettings
        case "deckTypeAnki":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let resultViewController = navViewController.viewControllers.first as? SelectDeckTypeTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            resultViewController.ankiSettings = ankiSettings
        case "editableCloze":
            guard let navViewController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let resultViewController = navViewController.viewControllers.first as? ClozeViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if let textRange = frontTextView.selectedTextRange {
                let clozedText = frontTextView.text(in: textRange) ?? ""
                resultViewController.cloze = clozedText
                resultViewController.hint = ""
                savedRange = textRange
            }
            resultViewController.surroundingText = surroundingText
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
            
            resultViewController.surroundingText = surroundingText
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
 
    @IBAction func unwindToAnkiView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SelectNoteTypeTableViewController {
            type = sourceViewController.selectedNoteType
            fields = noteTypes[String(sourceViewController.selectedNoteType)] ?? ["Front", "Back"]
            frontLabel.text = fields[0]
            backLabel.text = fields[1]
            
            typeButton.setTitle("Type: " + type, for: .normal)
            ankiSettings[1] = type
        } else if let sourceViewController = sender.source as? SelectDeckTypeTableViewController {
            deck = sourceViewController.selectedDeckType
            
            
            deckButton.setTitle("Deck: " + deck, for: .normal)
            ankiSettings[2] = deck
        } else if let sourceViewController = sender.source as? ClozeViewController {
            createCloze(clozedText: sourceViewController.clozeTextView.text, hintText: sourceViewController.hintTextView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView == frontTextView || textView == backTextView || textView == tagsTextView) && (text == "\t" || text == "\n") {
            if text == "\t" {
                if textView == frontTextView {
                    backTextView.becomeFirstResponder()
                }
                
                if textView == backTextView {
                    tagsTextView.becomeFirstResponder()
                }
                
                if textView == tagsTextView {
                    frontTextView.becomeFirstResponder()
                }
            } /*else if text == "\n"{
                addCard(self)
            }*/
            
            return false
        } else {
            return true
        }
    }
}

extension String {
    func countInstances(of stringToFind: String) -> Int {
        var stringToSearch = self
        var count = 0
        while let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) {
            stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
            count += 1
        }
        return count
    }
}

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}
