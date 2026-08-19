//
//  Message.swift
//  Stitchery
//
//  Created by Ethan Thomas on 5/1/25.
//

import Foundation
import FirebaseAuth
import FirebaseAuthInterop
import FirebaseCore
import FirebaseFirestore

struct Message: Identifiable, Codable, Hashable {
    @DocumentID var messageId: String?
    let fromId: String
    let told: String
    let messageTest: String
    let timestamp: Timestamp
    
    var user: User?
    
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
    var chatPartnerId: String {
        return fromId == Auth.auth().currentUser?.uid ? told : fromId
    }
    
    var isFromCurrentUser: Bool {
        return fromId == Auth.auth().currentUser?.uid
    }
}
