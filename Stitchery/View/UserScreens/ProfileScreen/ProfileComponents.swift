//
//  ProfileComponents.swift
//  Stitchery
//
//  Reusable, theme-matched building blocks for the profile screen.
//  These mirror the rounded card / icon-badge aesthetic used across the
//  app (see TailorDetailView) while keeping the profile brand palette
//  (navy `Color.main` + gold `Color.text`).
//

import SwiftUI

// MARK: - Avatar

/// Circular profile avatar that shows the user's remote photo when available,
/// otherwise their initials on the app's neutral background. An optional edit
/// badge can be overlaid to signal that the photo is editable.
struct ProfileAvatarView: View {
    let photoUrl: String?
    let initials: String
    var size: CGFloat = 110
    var showsEditBadge: Bool = false
    var localImage: Image? = nil

    var body: some View {
        avatar
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .overlay(alignment: .bottomTrailing) {
                if showsEditBadge {
                    Image(systemName: "pencil")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.main)
                        .padding(8)
                        .background(Circle().fill(Color.white))
                        .overlay(Circle().stroke(Color.main.opacity(0.15), lineWidth: 1))
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
                }
            }
    }

    @ViewBuilder
    private var avatar: some View {
        if let localImage {
            localImage
                .resizable()
                .scaledToFill()
        } else if let photoUrl, let url = URL(string: photoUrl), !photoUrl.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.3)
                        ProgressView()
                    }
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    initialsView
                }
            }
        } else {
            initialsView
        }
    }

    private var initialsView: some View {
        ZStack {
            Color.gray
            Text(initials)
                .font(.system(size: size * 0.32, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Card container

/// A rounded card container with an optional titled header, matching the
/// grouped-card style used elsewhere in the app.
struct ProfileCard<Content: View>: View {
    let title: String?
    @ViewBuilder var content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title {
                Text(title.uppercased())
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 6)
            }

            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Icon badge

/// A small rounded icon badge used as the leading element for profile rows.
struct ProfileIconBadge: View {
    let systemName: String
    var tint: Color = .main

    var body: some View {
        Image(systemName: systemName)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(tint)
            .frame(width: 30, height: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(tint.opacity(0.12))
            )
    }
}

// MARK: - Toggle row

/// A settings row with a leading icon badge, title/subtitle and a trailing toggle.
struct ProfileToggleRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = .main
    @Binding var isOn: Bool
    var showsDivider: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $isOn) {
                HStack(spacing: 12) {
                    ProfileIconBadge(systemName: icon, tint: tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .tint(.main)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if showsDivider {
                Divider().padding(.leading, 58)
            }
        }
    }
}

// MARK: - Tappable / navigation row

/// A tappable settings row with a leading icon badge, title/subtitle and a
/// trailing chevron. Used for navigation links and actions.
struct ProfileLinkRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = .main
    var showsChevron: Bool = true
    var showsDivider: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            ProfileIconBadge(systemName: icon, tint: tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(tint == .red ? Color.red : .primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showsDivider {
                Divider().padding(.leading, 58)
            }
        }
    }
}
