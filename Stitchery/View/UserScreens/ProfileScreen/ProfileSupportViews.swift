//
//  ProfileSupportViews.swift
//  Stitchery
//
//  Support & help destinations used by the profile screen:
//  an in-app Help Center (FAQs), a mail composer, and an in-app Safari view.
//

import SwiftUI
import SafariServices
import MessageUI

// MARK: - Help Center / FAQs

struct HelpCenterView: View {

    private struct FAQ: Identifiable {
        let id = UUID()
        let question: String
        let answer: String
    }

    private let faqs: [FAQ] = [
        FAQ(question: "How do I find a tailor near me?",
            answer: "Open the Search tab and allow location access. Stitchery lists nearby tailors with ratings, services and hours so you can pick the right fit."),
        FAQ(question: "How do I save a tailor?",
            answer: "Tap the heart on a tailor's detail page, or swipe on a search result. Saved tailors live under Favourites on your profile."),
        FAQ(question: "How do messages with tailors work?",
            answer: "Once you reach out to a tailor you can chat with them from the Messages tab. Enable “Tailor Messages” notifications to get alerted the moment they reply."),
        FAQ(question: "How do I update my profile photo or details?",
            answer: "Tap “Edit Profile” at the top of this screen to change your photo, display name and contact details."),
        FAQ(question: "Who can see my contact information?",
            answer: "Your contact details are only shared with a tailor when you choose to message or book with them.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(faqs) { faq in
                    ProfileCard {
                        DisclosureGroup {
                            Text(faq.answer)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        } label: {
                            HStack(spacing: 12) {
                                ProfileIconBadge(systemName: "questionmark.circle")
                                Text(faq.question)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .tint(.primary)
                        .padding(16)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - In-app Safari view

/// A lightweight wrapper around `SFSafariViewController` for showing web
/// content (privacy policy, terms of service) without leaving the app.
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Mail composer

/// A wrapper around `MFMailComposeViewController` used to contact support.
struct MailView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    var body: String = ""
    @Environment(\.dismiss) private var dismiss

    static var canSendMail: Bool { MFMailComposeViewController.canSendMail() }

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients([recipient])
        controller.setSubject(subject)
        controller.setMessageBody(body, isHTML: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            dismiss()
        }
    }
}
