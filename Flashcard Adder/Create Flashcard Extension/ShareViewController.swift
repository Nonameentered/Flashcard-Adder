//
//  ShareViewController.swift
//  Create Flashcard
//
//  Created by Matthew Shu on 9/14/20.
//

import Social
import UIKit

class ShareViewController: UIViewController {
    @IBOutlet var frontField: EditFieldTextView!
    @IBOutlet var backField: EditFieldTextView!
    var flashcard = Flashcard(originalText: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return
        }
        if let inputText = inputItems.first?.attributedContentText?.string {
            flashcard = Flashcard(originalText: inputText)
        }
        frontField.text = flashcard.fields[0].text
        */
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        let error = NSError(domain: "com.technaplex.Flashcard-Adder.Create-Flashcard", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cancel Button Tapped"])
        extensionContext?.cancelRequest(withError: error)
    }

    @IBAction func createButtonTapped(_ sender: UIBarButtonItem) {
        /*
        flashcard.fields[0].text = frontField.text
        flashcard.fields[1].text = backField.text
        flashcard.note = FlashcardSettings.shared.defaultNoteType
        flashcard.deck = FlashcardSettings.shared.defaultDeck
        */
        extensionContext?.completeRequest(returningItems: []) { expired in
            if expired {
                self.extensionContext?.cancelRequest(withError: NSError(domain: "com.technaplex.Flashcard-Adder.Create-Flashcard", code: 1, userInfo: [NSLocalizedDescriptionKey: "Previous invocation still terminating"]))
            } else {}
        }
    }
}

// https://diamantidis.github.io/2020/01/11/share-extension-custom-ui
// @objc(CustomShareNavigationController)
// class CustomShareNavigationController: UINavigationController {
//
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//
//        // 2: set the ViewControllers
//        self.setViewControllers([ShareViewController()], animated: false)
//    }
//
//    @available(*, unavailable)
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
// }

// class ShareViewController: SLComposeServiceViewController {
//
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }
//
// }
