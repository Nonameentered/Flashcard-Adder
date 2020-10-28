//
//  NoteViewController.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/27/20.
//

import UIKit

protocol NoteViewControllerDelegate {
    func addNote(note: Note)
    func editNote(old: AttributedNote, new: Note)
}

class NoteViewController: UIViewController {
    let initialNote: AttributedNote?
    var delegate: NoteViewControllerDelegate?
    var stackView: UIStackView!
    var fieldViews: [UITextView]!

    convenience init() {
        self.init(note: nil)
    }

    init(note: AttributedNote?) {
        self.initialNote = note

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView()
        view.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)

        setUpNavBar()
    }

    func setUpNavBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        let editButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(edit))
        navigationItem.leftBarButtonItems = [doneButton]
        if initialNote == nil {
            navigationItem.rightBarButtonItems = [addButton]
            navigationItem.title = "Add Note"
        } else {
            navigationItem.rightBarButtonItems = [editButton]
            navigationItem.title = "Edit Note"
        }
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func add() {
        delegate?.addNote(note: Note(name: "CHICKEN"))
    }

    @objc func edit() {
        if let initialNote = initialNote {
            delegate?.editNote(old: initialNote, new: Note(name: "CHICKdfsdf"))
        }
    }
}
