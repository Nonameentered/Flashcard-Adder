//
//  LabelTableViewCell.swift
//  Flashcard Adder
//
//  Created by Matthew on 12/25/18.
//

import UIKit

class LabelTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
