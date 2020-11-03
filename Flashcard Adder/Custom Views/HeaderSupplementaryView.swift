//
//  HeaderSupplementaryView.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/24/20.
//

import UIKit

class HeaderSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    static let reuseIdentifier = "header-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension HeaderSupplementaryView {
    // Code taken from Apple's Modern Collection Views example project
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        let inset = CGFloat(5)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .callout)
    }
}
