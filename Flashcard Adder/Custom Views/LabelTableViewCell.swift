//
//  LabelTableViewCell.swift
//  Flashcard Adder
//
//  Created by Matthew on 12/25/18.
//

import UIKit
// TODO: CHECK IF NEEDED
class LabelTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
