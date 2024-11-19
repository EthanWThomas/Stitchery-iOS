//
//  User.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/13/24.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    
    var initial: String {
        let formater = PersonNameComponentsFormatter()
        if let components = formater.personNameComponents(from: name) {
            formater.style = .abbreviated
            return formater.string(from: components)
        }
        return ""
    }
}
