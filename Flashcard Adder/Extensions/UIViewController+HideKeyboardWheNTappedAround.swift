//
//  UIViewController+HideKeyboardWheNTappedAround.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 9/24/20.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
