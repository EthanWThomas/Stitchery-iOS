//
//  ChatPartner.swift
//  Stitchery
//
//  Created by Ethan Thomas on 8/10/26.
//

import Foundation

/// A unified representation of anyone the current user can chat with.
///
/// Today a `ChatPartner` is almost always a tailor (sourced from Google/SerpAPI
/// data, which is *not* a Firebase account), but the same type can wrap a real
/// `User` if two-sided user-to-user chat is added later. Keeping the messaging
/// layer built around this type means the chat UI and view model never need to
/// care whether the other side is a tailor or a user.
struct ChatPartner: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let photoUrl: String?
    var specialty: String?
    var address: String?
    var phone: String?
    var kind: Kind

    enum Kind: String, Codable {
        case tailor
        case user
    }
}

extension ChatPartner {
    /// Builds a chat partner from a tailor search result.
    init(tailor: GoogleMapsLocalResults.LocalResults) {
        self.init(
            id: tailor.chatPartnerId,
            name: tailor.title,
            photoUrl: tailor.thumbnail,
            specialty: tailor.type,
            address: tailor.address,
            phone: tailor.phone,
            kind: .tailor
        )
    }

    /// Builds a chat partner from a saved (SwiftData) tailor.
    init(dataModel tailor: LocalResultsDataModel) {
        self.init(
            id: tailor.chatPartnerId,
            name: tailor.title,
            photoUrl: tailor.thumbnail,
            specialty: tailor.type,
            address: tailor.address,
            phone: tailor.phone,
            kind: .tailor
        )
    }

    /// Rebuilds a chat partner from a stored inbox conversation summary.
    init(conversation: Conversation) {
        self.init(
            id: conversation.partnerId,
            name: conversation.partnerName,
            photoUrl: conversation.partnerPhotoUrl,
            specialty: conversation.partnerSpecialty,
            address: nil,
            phone: nil,
            kind: .tailor
        )
    }

    /// Builds a chat partner from an app user (for future user-to-user chat).
    init(user: User) {
        self.init(
            id: user.id,
            name: user.fullname,
            photoUrl: user.photoUrl,
            specialty: nil,
            address: nil,
            phone: nil,
            kind: .user
        )
    }
}

extension GoogleMapsLocalResults.LocalResults {
    /// A stable, Firestore-safe identifier used to key a tailor's conversation.
    ///
    /// Prefers the Google `place_id` (globally unique and durable). When that is
    /// missing it falls back to `placeIdSearch`, and finally to a deterministic
    /// slug derived from the title and coordinates so the same tailor always
    /// resolves to the same conversation.
    var chatPartnerId: String {
        if let placeId, !placeId.isEmpty { return placeId }
        if let placeIdSearch, !placeIdSearch.isEmpty { return placeIdSearch }

        let latitude = gpsCoordinates.latitude ?? 0
        let longitude = gpsCoordinates.longitude ?? 0
        return "\(title)_\(latitude)_\(longitude)"
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
    }
}

extension LocalResultsDataModel {
    /// A stable, Firestore-safe identifier used to key a saved tailor's
    /// conversation. Prefers the Google `place_id` so it matches the id used by
    /// the live search result for the same tailor.
    var chatPartnerId: String {
        if let placeId, !placeId.isEmpty { return placeId }
        if let placeIdSearch, !placeIdSearch.isEmpty { return placeIdSearch }

        return title
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
    }
}
