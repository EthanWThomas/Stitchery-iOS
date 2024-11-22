//
//  User.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/13/24.
//

import Foundation

struct User: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var fullname: String
    var email: String
    var photoUrl: String?
    
    var initial: String {
        let formater = PersonNameComponentsFormatter()
        if let components = formater.personNameComponents(from: fullname) {
            formater.style = .abbreviated
            return formater.string(from: components)
        }
        return ""
    }
    
    func isFromCurrentUser() -> Bool {
        guard let currUser = AuthManger.shared.getCurrentUser() else {
            return false
        }
        
        if currUser.Uid == id {
            return true
        } else {
            return false
        }
    }
    
    func fetchPhotoURL() -> URL? {
        guard let photoURLString = photoUrl, let url = URL(string: photoURLString) else {
            return nil
        }
        
        return url
    }
}
