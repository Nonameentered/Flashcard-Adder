//
//  RoundBorderButton.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/15/20.
//  Copyright © 2020 Technaplex. All rights reserved.
//

import UIKit

class BigButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setUpView(title: title)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView(title: String? = nil) {
        if let title = title {
            setTitle(title, for: .normal)
        }
        backgroundColor = UIColor(named: "backgroundColor")
        
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "tintColor")!.cgColor
        
        adjustsImageWhenDisabled = true
        adjustsImageWhenHighlighted = true
    }
}
