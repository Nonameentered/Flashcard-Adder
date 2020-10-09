//
//  SelectDeckTypeTableViewController.swift
//  iQuiz
//
//  Created by Matthew on 12/25/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

class SelectDeckTypeTableViewController: UITableViewController {
//    var deckTypes: [String] = UserDefaults.standard.object(forKey: "ankiDeckOptions") as? [String] ?? ["Default", "Quizbowl"]
//    var ankiSettings = UserDefaults.standard.object(forKey: "ankiDefaults") as? Array<String> ?? ["User 1", "Basic", "Default", "Front", "Back", ""]
//    var selectedDeckType = "Default"
    var deck = FlashcardSettings.shared.defaultDeck
    var decks = FlashcardSettings.shared.decks
    
    //var selecteddeckType = UserDefaults.standard.object(forKey: "ankiDefaults") as? String ?? "Basic"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return decks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let deck = tableView.dequeueReusableCell(withIdentifier: "deck", for: indexPath) as? LabelTableViewCell else {
            fatalError("The dequeued cell is not an instance of LabelTableViewCell.")
        }
        
        deck.label.text = decks[indexPath.row].name
        if deck.label.text == self.deck.name {
            deck.accessoryType = .checkmark
        } else {
            deck.accessoryType = .none
        }
        
        return deck
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
         if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
         tableView.cellForRow(at: indexPath)?.accessoryType = .none
         } else {
         tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
         }*/
        
        guard let deckRow = tableView.cellForRow(at: indexPath) as? LabelTableViewCell else {
            fatalError("The dequeued cell is not an instance of LabelTableViewCell.")
        }
        
        deck = decks.first(where: {$0.name == deckRow.label.text}) ?? FlashcardSettings.shared.defaultDeck
        
        performSegue(withIdentifier: "deckTypeUnwind", sender: self)
    }
    
    @IBAction func unwindToSelectDeckView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddDeckViewController {
            let newDeck = Deck(name: sourceViewController.deckNameField.text)
            decks.append(newDeck)
            FlashcardSettings.shared.decks = decks
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            self.decks.remove(at: indexPath.row)
            FlashcardSettings.shared.decks = self.decks
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        /*let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.deckTypes[indexPath.row])")
        }*/
        
        //share.backgroundColor = UIColor.lightGray
        
        return [delete]
        
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
