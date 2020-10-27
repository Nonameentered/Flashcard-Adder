//
//  Profile.swift
//  
//
//  Created by Matthew Shu on 9/18/20.
//

import Foundation

struct Profile: Codable, Hashable, Option {
    static let typeName: String = "Profile"
    static let typeNamePlural: String = "Profiles"
    
    let name: String
}
