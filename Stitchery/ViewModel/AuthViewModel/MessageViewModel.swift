//
//  MessageViewModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 5/1/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Drives tailor messaging.
///
/// Firestore layout used here:
/// - `conversations/{conversationId}/messages/{messageId}` – the message thread
/// - `users/{uid}/conversations/{conversationId}`          – per-user inbox summary
/// - `tailors/{partnerId}`                                 – lightweight tailor profile
///
/// `conversationId` is deterministic (`"{uid}_{partnerId}"`), so the same
/// user/tailor pair always resolves to the same thread. This keeps a single
/// source of truth for messages (rather than duplicating them per participant)
/// and makes adding a real tailor side later straightforward.
@Observable
@MainActor
class MessageViewModel {

    private let db = Firestore.firestore()

    /// Messages for the currently observed thread, oldest first.
    var messages: [Message] = []

    /// Inbox summaries for the signed-in user, newest activity first.
    var conversations: [Conversation] = []

    private var messagesListener: ListenerRegistration?
    private var conversationsListener: ListenerRegistration?

    private var currentUid: String? {
        Auth.auth().currentUser?.uid
    }

    // MARK: - Conversation Identity

    /// Deterministic conversation id for the signed-in user and a partner.
    /// Returns `nil` when no user is signed in.
    func conversationId(for partnerId: String) -> String? {
        guard let currentUid else { return nil }
        return "\(currentUid)_\(partnerId)"
    }

    // MARK: - Sending

    /// Sends a message to a tailor (or any chat partner) and updates the inbox.
    func sendMessage(_ text: String, to partner: ChatPartner) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let currentUid, let conversationId = conversationId(for: partner.id) else { return }

        let messageRef = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document()

        let message = Message(
            messageId: messageRef.documentID,
            fromId: currentUid,
            told: partner.id,
            messageTest: trimmed,
            timestamp: Timestamp()
        )

        guard let messageData = try? Firestore.Encoder().encode(message) else { return }

        messageRef.setData(messageData)
        upsertConversationSummary(conversationId: conversationId, partner: partner, lastMessage: trimmed)
        ensureTailorProfile(partner)
    }

    // MARK: - Observing a Thread

    /// Starts a live listener for the thread with `partner`, streaming into `messages`.
    func observeMessages(with partner: ChatPartner) {
        guard let conversationId = conversationId(for: partner.id) else { return }

        messagesListener?.remove()
        messages = []

        messagesListener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self?.messages = documents.compactMap { try? $0.data(as: Message.self) }
            }
    }

    /// Detaches the thread listener. Call from the chat view's `onDisappear`.
    func stopObservingMessages() {
        messagesListener?.remove()
        messagesListener = nil
    }

    // MARK: - Observing the Inbox

    /// Starts a live listener for the signed-in user's conversation list.
    func observeConversations() {
        guard let currentUid else { return }

        conversationsListener?.remove()

        conversationsListener = db.collection("users")
            .document(currentUid)
            .collection("conversations")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self?.conversations = documents.compactMap { try? $0.data(as: Conversation.self) }
            }
    }

    /// Detaches the inbox listener. Call from the inbox view's `onDisappear`.
    func stopObservingConversations() {
        conversationsListener?.remove()
        conversationsListener = nil
    }

    // MARK: - Private Writes

    /// Creates or updates the per-user inbox summary for a conversation.
    private func upsertConversationSummary(
        conversationId: String,
        partner: ChatPartner,
        lastMessage: String
    ) {
        guard let currentUid else { return }

        let conversation = Conversation(
            id: conversationId,
            partnerId: partner.id,
            partnerName: partner.name,
            partnerPhotoUrl: partner.photoUrl,
            partnerSpecialty: partner.specialty,
            lastMessage: lastMessage,
            timestamp: Timestamp()
        )

        guard let data = try? Firestore.Encoder().encode(conversation) else { return }

        db.collection("users")
            .document(currentUid)
            .collection("conversations")
            .document(conversationId)
            .setData(data, merge: true)
    }

    /// Persists a lightweight tailor profile so the conversation is resolvable
    /// from the tailor side (and for a future tailor dashboard).
    private func ensureTailorProfile(_ partner: ChatPartner) {
        guard partner.kind == .tailor else { return }

        let data: [String: Any] = [
            "id": partner.id,
            "name": partner.name,
            "photoUrl": partner.photoUrl as Any,
            "specialty": partner.specialty as Any,
            "address": partner.address as Any,
            "phone": partner.phone as Any
        ]

        db.collection("tailors").document(partner.id).setData(data, merge: true)
    }
}
