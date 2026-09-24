//
//  ChatThreadView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 8/11/26.
//

import SwiftUI
import FirebaseAuth

/// The conversation screen for a single tailor. Streams messages live, keeps
/// the newest message in view, and sends via `MessageViewModel`.
struct ChatThreadView: View {
    let partner: ChatPartner

    @Environment(TabBarVisibility.self) private var tabBarVisibility

    @State private var viewModel = MessageViewModel()
    @State private var messageText = ""

    @State private var showAppointmentSheet = false
    @State private var appointmentDate = Date()
    @State private var appointmentNote = ""

    init(partner: ChatPartner) {
        self.partner = partner
    }

    /// Convenience entry point used from the tailor detail screen.
    init(tailor: GoogleMapsLocalResults.LocalResults) {
        self.partner = ChatPartner(tailor: tailor)
    }

    private var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if isSignedIn {
                messagesList
                inputBar
            } else {
                signedOutState
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showAppointmentSheet) {
            appointmentSheet
        }
        .onAppear {
            tabBarVisibility.isHidden = true
            if isSignedIn {
                viewModel.observeMessages(with: partner)
            }
        }
        .onDisappear {
            tabBarVisibility.isHidden = false
            viewModel.stopObservingMessages()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            CircuiarProfileImageView(partner: partner, size: .small)

            VStack(alignment: .leading, spacing: 2) {
                Text(partner.name)
                    .font(.headline)
                    .lineLimit(1)

                if let specialty = partner.specialty, !specialty.isEmpty {
                    Text(specialty)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            if isSignedIn {
                Button {
                    appointmentDate = Date()
                    appointmentNote = ""
                    showAppointmentSheet = true
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title3)
                        .foregroundStyle(Color.blue)
                }
                .accessibilityLabel("Request appointment")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    // MARK: - Appointment Scheduling

    private var appointmentSheet: some View {
        NavigationStack {
            Form {
                Section("When") {
                    DatePicker(
                        "Date & time",
                        selection: $appointmentDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Note (optional)") {
                    TextField("What do you need? e.g. suit alteration", text: $appointmentNote, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Request Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAppointmentSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { sendAppointmentRequest() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Messages

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(message: message, partner: partner)
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .overlay {
                if viewModel.messages.isEmpty {
                    emptyState
                }
            }
            .onChange(of: viewModel.messages.count) {
                scrollToBottom(proxy)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Start the conversation", systemImage: "bubble.left.and.bubble.right")
        } description: {
            Text("Say hello to \(partner.name) or ask about booking an appointment.")
        }
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Message \(partner.name)…", text: $messageText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(Color(.secondarySystemBackground))
                )

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? Color.blue : Color(.systemGray3))
            }
            .disabled(!canSend)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    // MARK: - Signed Out

    private var signedOutState: some View {
        ContentUnavailableView {
            Label("Sign in to message", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("You need to be signed in to chat with \(partner.name).")
        }
        .frame(maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Actions

    private func send() {
        guard canSend else { return }
        viewModel.sendMessage(messageText, to: partner)
        messageText = ""
    }

    private func sendAppointmentRequest() {
        let when = appointmentDate.formatted(date: .abbreviated, time: .shortened)
        var text = "📅 Appointment request for \(when)."
        let note = appointmentNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if !note.isEmpty {
            text += " Note: \(note)"
        }
        viewModel.sendMessage(text, to: partner)
        showAppointmentSheet = false
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard let lastId = viewModel.messages.last?.id else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }
}

//#Preview {
//    NavigationStack {
//        ChatThreadView(
//            partner: ChatPartner(
//                id: "preview",
//                name: "Ace Tailoring",
//                photoUrl: nil,
//                specialty: "Suits • Alterations",
//                address: nil,
//                phone: nil,
//                kind: .tailor
//            )
//        )
//    }
//}
