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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(noteView)
        return scrollView
    }()
    var noteView: NoteView!
    var addButton: UIBarButtonItem!

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
        
        setUpView()
        setUpNavBar()
    }

    func setUpNavBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
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
    
    func setUpView() {
        noteView = NoteView(initialNote: initialNote?.source, axis: .vertical)
        noteView.delegate = self
        view.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)
        view.addSubview(scrollView)
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            frameGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            frameGuide.topAnchor.constraint(equalTo: view.topAnchor),
            frameGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            frameGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentGuide.leadingAnchor.constraint(equalTo: noteView.leadingAnchor, constant: -8),
            contentGuide.trailingAnchor.constraint(equalTo: noteView.trailingAnchor, constant: 8),
            contentGuide.bottomAnchor.constraint(equalTo: noteView.bottomAnchor, constant: 20),
            contentGuide.topAnchor.constraint(equalTo: noteView.topAnchor, constant: -20.0),
            contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            ])
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func add() {
        if let note = noteView.note {
            delegate?.addNote(note: note)
            dismiss(animated: true, completion: nil)
        }
    }

    @objc func edit() {
        if let initialNote = initialNote, let note = noteView.note {
            print("EDITED NOTE")
            delegate?.editNote(old: initialNote, new: note)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension NoteViewController: NoteViewDelegate {
    func noteUpdated() {
        addButton.isEnabled = noteView.note != nil
    }
}
