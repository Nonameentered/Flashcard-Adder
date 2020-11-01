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
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .default)
        setImage(UIImage(systemName: "star", withConfiguration: largeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.systemGray), for: .normal)
        setImage(UIImage(systemName: "star.fill", withConfiguration: largeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.systemYellow), for: .selected)
//        tintColor = .systemGray
//        print(isSelected)
        addTarget(self, action: #selector(setSelected), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setSelected() {
        isSelected = !isSelected
//        tintColor = isSelected ? UIColor.systemYellow : UIColor.systemGray
    }
}
