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
    private enum ViewMetrics {
        static let margin: CGFloat = 20.0
    }
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        return scrollView
    }()
    var stackView: UIStackView = {
        let textView = EditFieldTextView()
        textView.isScrollEnabled = false
        textView.text = "CHICKEN"
        textView.translatesAutoresizingMaskIntoConstraints = false
        let textView2 = EditFieldTextView()
        textView2.isScrollEnabled = false
        textView2.text = "CHICKEN NOODLEs"
        textView2.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [textView, textView2])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
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
        view.backgroundColor = UIColor(named: FlashcardSettings.Colors.backgroundColor)
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: ViewMetrics.margin, leading: ViewMetrics.margin, bottom: ViewMetrics.margin, trailing: ViewMetrics.margin)
        
        view.addSubview(scrollView)
        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            frameGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            frameGuide.topAnchor.constraint(equalTo: view.topAnchor),
            frameGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            frameGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            contentGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
            contentGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            contentGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),

            contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            ])
        setUpNavBar()
        print(stackView.arrangedSubviews[0])
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
