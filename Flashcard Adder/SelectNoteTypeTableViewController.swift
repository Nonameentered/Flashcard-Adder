//
//  SelectNoteTypeTableViewController.swift
//  iQuiz
//
//  Created by Matthew on 12/25/18.
//  Copyright © 2018 Innoviox. All rights reserved.
//

import UIKit

class SelectNoteTypeTableViewController: UITableViewController {
    var noteTypes: [String:[String]] = UserDefaults.standard.object(forKey: "ankiNoteOptions") as? [String:[String]] ?? ["Basic":["Front", "Back"], "Cloze":["Text", "Extra"]]
    //var ankiSettings: [String] = UserDefaults.standard.object(forKey: "ankiDefaults") as? Array<String> ?? ["User 1", "Basic", "Default", "Front", "Back", ""]
    var ankiSettings: [String] = ["User 1", "Basic", "Default", "Front", "Back", ""]
    var selectedNoteType = "Basic"
    //var selectedNoteType = UserDefaults.standard.object(forKey: "ankiDefaults") as? String ?? "Basic"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedNoteType = ankiSettings[1]
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
        return noteTypes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let noteType = tableView.dequeueReusableCell(withIdentifier: "noteType", for: indexPath) as? LabelTableViewCell else {
            fatalError("The dequeued cell is not an instance of LabelTableViewCell.")
        }
        
        var notesArray = Array(noteTypes.keys).sorted()
        noteType.label.text = notesArray[indexPath.row]
        if noteType.label.text == ankiSettings[1] {
            noteType.accessoryType = .checkmark
        } else {
            noteType.accessoryType = .none
        }
        return noteType
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }*/
        
        guard let noteTypeRow = tableView.cellForRow(at: indexPath) as? LabelTableViewCell else {
            fatalError("The dequeued cell is not an instance of LabelTableViewCell.")
        }
        
        selectedNoteType = noteTypeRow.label.text ?? "Basic"
        
        performSegue(withIdentifier: "noteTypeUnwind", sender: self)
    }
    
    @IBAction func unwindToSelectNoteView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddNoteViewController {
            noteTypes.updateValue([sourceViewController.firstNameField.text, sourceViewController.secondNameField.text], forKey: sourceViewController.noteNameField.text)
            UserDefaults.standard.set(noteTypes, forKey: "ankiNoteOptions")
            tableView.reloadData()
            /*
             if ankiSettings[1] == "Cloze" {
             clozeButton.isHidden = false
             } else {
             clozeButton.isHidden = true
             }*/
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            var noteTypesKeys = Array(self.noteTypes.keys).sorted()
            self.noteTypes.removeValue(forKey: noteTypesKeys[indexPath.row])
            UserDefaults.standard.set(self.noteTypes, forKey: "ankiNoteOptions")
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
