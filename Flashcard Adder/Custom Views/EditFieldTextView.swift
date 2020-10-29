//
//  EditFieldTextView.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//  Copyright © 2020 Technaplex. All rights reserved.
//

import UIKit

class EditFieldTextView: UITextView {
    convenience init() {
        self.init(frame: .zero, textContainer: nil)
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUpView()
    }
    
    private func setUpView() {
        backgroundColor = UIColor(named: "backgroundColor")
        textColor = UIColor(named: "textColor")

        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "tintColor")!.cgColor
    }
}
