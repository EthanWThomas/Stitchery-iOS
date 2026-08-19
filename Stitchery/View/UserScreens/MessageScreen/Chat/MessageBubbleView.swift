//
//  MessageBubbleView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 8/11/26.
//

import SwiftUI
import FirebaseFirestore

/// A single message row, aligned to the sending side and using the app's
/// `ChatBubble` shape. Incoming messages show the partner's avatar.
struct MessageBubbleView: View {
    let message: Message
    let partner: ChatPartner

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromCurrentUser {
                Spacer(minLength: 44)
                content
            } else {
                CircuiarProfileImageView(partner: partner, size: .xSmall)
                content
                Spacer(minLength: 44)
            }
        }
    }

    private var content: some View {
        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 3) {
            Text(message.messageTest)
                .font(.subheadline)
                .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.isFromCurrentUser
                        ? Color.blue
                        : Color(.secondarySystemBackground)
                )
                .clipShape(ChatBubble(isFromCurrentUser: message.isFromCurrentUser))
                .fixedSize(horizontal: false, vertical: true)

            Text(message.timestamp.dateValue(), format: .dateTime.hour().minute())
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
        }
    }
}
