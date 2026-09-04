//
//  ProfileView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileScreen: View {

    @Environment(AuthViewModel.self) var viewModel
    @Environment(\.openURL) private var openURL

    @State var swiftDataVM: GoogleMapVM

    // MARK: Sheets / navigation state
    @State private var showEditProfile = false
    @State private var showMailSheet = false
    @State private var webLink: WebLink?

    // MARK: Notification preferences (persisted locally)
    @AppStorage("notif.tailorMessages") private var tailorMessages = true
    @AppStorage("notif.orderStatus") private var orderStatus = true
    @AppStorage("notif.promotions") private var promotions = false

    private let supportEmail = "support@stitchery.app"
    private let privacyURL = URL(string: "https://www.stitchery.app/privacy")!
    private let termsURL = URL(string: "https://www.stitchery.app/terms")!

    init(context: ModelContext) {
        self.swiftDataVM = GoogleMapVM(context: context)
    }

    private var user: User? { viewModel.activeUser }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user {
                    VStack(spacing: 20) {
                        header(for: user)
                        accountCard
                        preferencesCard
                        supportCard
                        versionFooter
                    }
                    .padding(.bottom, 32)
                } else {
                    signedOutState
                }
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showEditProfile) {
                if let user { EditProfileView(user: user) }
            }
            .sheet(isPresented: $showMailSheet) {
                MailView(recipient: supportEmail,
                         subject: "Stitchery Support",
                         body: "\n\n—\nSent from the Stitchery app")
            }
            .sheet(item: $webLink) { link in
                SafariView(url: link.url)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Header

    private func header(for user: User) -> some View {
        VStack(spacing: 14) {
            ProfileAvatarView(
                photoUrl: user.photoUrl,
                initials: user.initial.isEmpty ? "?" : user.initial,
                size: 104,
                showsEditBadge: true
            )
            .onTapGesture { showEditProfile = true }

            VStack(spacing: 4) {
                Text(user.fullname)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.text)

                if !user.email.isEmpty && user.email != "Unknown" {
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                if let phone = user.phoneNumber, !phone.isEmpty {
                    Text(phone)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .multilineTextAlignment(.center)

            Button {
                showEditProfile = true
            } label: {
                Label("Edit Profile", systemImage: "pencil")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.main)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.text))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 28)
        .background(
            Color.main
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Account

    private var accountCard: some View {
        ProfileCard("Account") {
            NavigationLink {
                SavedTailorView(viewModel: swiftDataVM)
            } label: {
                ProfileLinkRow(icon: "heart", title: "Favourites",
                               subtitle: "Your saved tailors")
            }
            .buttonStyle(.plain)

            Button {
                viewModel.signOut()
            } label: {
                ProfileLinkRow(icon: "arrow.left.circle.fill", title: "Sign Out",
                               tint: .red, showsChevron: false, showsDivider: false)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Preferences

    private var preferencesCard: some View {
        ProfileCard("Preferences") {
            ProfileToggleRow(
                icon: "bell.badge",
                title: "Tailor Messages",
                subtitle: "Get alerted when a tailor replies or updates an order.",
                isOn: $tailorMessages
            )
            ProfileToggleRow(
                icon: "shippingbox",
                title: "Order Status Updates",
                subtitle: "Notify me when an order changes status.",
                isOn: $orderStatus
            )
            ProfileToggleRow(
                icon: "megaphone",
                title: "Promotions & News",
                subtitle: "Occasional offers and app updates.",
                isOn: $promotions,
                showsDivider: false
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Support

    private var supportCard: some View {
        ProfileCard("Support") {
            Button {
                contactSupport()
            } label: {
                ProfileLinkRow(icon: "envelope", title: "Contact Support",
                               subtitle: "We usually reply within a day")
            }
            .buttonStyle(.plain)

            NavigationLink {
                HelpCenterView()
            } label: {
                ProfileLinkRow(icon: "questionmark.circle", title: "FAQs & Help Center")
            }
            .buttonStyle(.plain)

            Button {
                webLink = WebLink(url: privacyURL)
            } label: {
                ProfileLinkRow(icon: "lock.shield", title: "Privacy Policy")
            }
            .buttonStyle(.plain)

            Button {
                webLink = WebLink(url: termsURL)
            } label: {
                ProfileLinkRow(icon: "doc.text", title: "Terms of Service",
                               showsDivider: false)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Footer

    private var versionFooter: some View {
        Text("Stitchery \(appVersion)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 4)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    // MARK: - Signed-out state

    private var signedOutState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("You're signed out")
                .font(.headline)
            Text("Sign in to view and manage your profile.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    // MARK: - Actions

    private func contactSupport() {
        if MailView.canSendMail {
            showMailSheet = true
        } else if let url = URL(string: "mailto:\(supportEmail)") {
            openURL(url)
        }
    }
}

/// Identifiable wrapper so URLs can drive an item-based sheet.
private struct WebLink: Identifiable {
    let id = UUID()
    let url: URL
}

//#Preview {
//    ProfileScreen()
//}
