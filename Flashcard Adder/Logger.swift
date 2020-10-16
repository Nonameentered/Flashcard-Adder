//
//  Logger.swift
//  Flashcard Adder
//
//  Created by Matthew Shu on 10/15/20.
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    // Example from https://www.avanderlee.com/workflow/oslog-unified-logging/
    /// Logs the view cycles like viewDidLoad.
    static let segue = Logger(subsystem: subsystem, category: "segue")
    static let note = Logger(subsystem: subsystem, category: "note")
    static let flashcard = Logger(subsystem: subsystem, category: "flashcard")
}
