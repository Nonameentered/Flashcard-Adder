//
//  EditFieldTextView.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//  Copyright © 2020 Technaplex. All rights reserved.
//

import UIKit

class EditFieldTextView: UITextView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor(named: "backgroundColor")
        textColor = UIColor(named: "textColor")
        
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "tintColor")!.cgColor
    }

}
