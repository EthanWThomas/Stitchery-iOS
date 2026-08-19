//
//  Conversation.swift
//  Stitchery
//
//  Created by Ethan Thomas on 8/10/26.
//

import Foundation
import FirebaseFirestore

/// A lightweight inbox summary for a single tailor conversation.
///
/// One document is stored per user at
/// `users/{uid}/conversations/{conversationId}` and is upserted every time a
/// message is sent, so the Message tab can show an inbox (partner + last
/// message + time) without reading every message in every thread.
struct Conversation: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let partnerId: String
    let partnerName: String
    let partnerPhotoUrl: String?
    let partnerSpecialty: String?
    let lastMessage: String
    let timestamp: Timestamp
}
