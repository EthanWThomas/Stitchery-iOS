//
//  MessageRoom.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI
import FirebaseAuth

/// The Messages tab: an inbox of the user's tailor conversations.
struct MessageRoom: View {
    @State private var viewModel = MessageViewModel()

    private var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if !isSignedIn {
                    signedOutState
                } else if viewModel.conversations.isEmpty {
                    emptyState
                } else {
                    conversationList
                }
            }
            .navigationTitle("Messages")
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            if isSignedIn {
                viewModel.observeConversations()
            }
        }
        .onDisappear {
            viewModel.stopObservingConversations()
        }
    }

    // MARK: - Inbox List

    private var conversationList: some View {
        List {
            ForEach(viewModel.conversations) { conversation in
                NavigationLink {
                    ChatThreadView(partner: ChatPartner(conversation: conversation))
                } label: {
                    ConversationRow(conversation: conversation)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Empty / Signed Out States

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No messages yet", systemImage: "bubble.left.and.bubble.right")
        } description: {
            Text("Find a tailor and start a chat to book an appointment.")
        }
    }

    private var signedOutState: some View {
        ContentUnavailableView {
            Label("Sign in to view messages", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("Your tailor conversations will appear here once you're signed in.")
        }
    }
}

/// A single inbox row: avatar, tailor name, last message preview, and time.
private struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {
            CircuiarProfileImageView(photoUrl: conversation.partnerPhotoUrl, size: .medium)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(conversation.partnerName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(conversation.timestamp.dateValue(), format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(conversation.lastMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    MessageRoom()
}
