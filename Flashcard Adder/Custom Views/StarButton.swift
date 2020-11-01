//
//  StarButton.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 11/1/20.
//

import UIKit

class StarButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .default)
        setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
        setImage(UIImage(systemName: "star.fill", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.systemYellow), for: .selected)
        addTarget(self, action: #selector(setSelected), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setSelected() {
        isSelected = !isSelected
    }
}
