//
//  TailorDetillView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/13/24.
//

import SwiftUI
import SwiftData

struct TailorDetailView: View {
    var tailor: GoogleMapsLocalResults.LocalResults

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var openStateExpanded = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TailorHeroHeader(
                    thumbnail: tailor.thumbnail,
                    title: tailor.title,
                    type: tailor.type,
                    openState: tailor.openState
                )

                statsRow

                contactCard

                aboutCard

                servicesCard

                TailorHoursCard(
                    operatingHours: tailor.operatingHours,
                    openState: tailor.openState,
                    isExpanded: $openStateExpanded
                )

                messageButton

                mapButton
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(tailor.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            TailorStat(
                icon: "star.fill",
                value: String(format: "%.1f", tailor.rating ?? 0.0),
                label: "Rating"
            )
            TailorStat(
                icon: "text.bubble.fill",
                value: "\(tailor.reviews ?? 0)",
                label: "Reviews"
            )
            if let price = tailor.price, !price.isEmpty {
                TailorStat(
                    icon: "dollarsign.circle.fill",
                    value: price,
                    label: "Price"
                )
            }
        }
    }

    private var contactCard: some View {
        TailorCard(title: "Contact", systemImage: "phone.circle.fill") {
            VStack(spacing: 14) {
                TailorInfoRow(
                    icon: "mappin.circle.fill",
                    title: "Address",
                    value: tailor.address
                )

                Divider()

                if let phone = tailor.phone, !phone.isEmpty {
                    Button {
                        openTel(phone)
                    } label: {
                        TailorInfoRow(
                            icon: "phone.fill",
                            title: "Phone",
                            value: phone,
                            valueColor: .blue,
                            showChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    TailorInfoRow(
                        icon: "phone.fill",
                        title: "Phone",
                        value: "No phone number",
                        valueColor: .secondary
                    )
                }

                Divider()

                websiteRow
            }
        }
    }

    @ViewBuilder
    private var websiteRow: some View {
        if let website = tailor.website, !website.isEmpty, let url = URL(string: website) {
            Link(destination: url) {
                TailorInfoRow(
                    icon: "globe",
                    title: "Website",
                    value: website,
                    valueColor: .blue,
                    showChevron: true
                )
            }
            .buttonStyle(.plain)
        } else {
            TailorInfoRow(
                icon: "globe",
                title: "Website",
                value: "No website available",
                valueColor: .secondary
            )
        }
    }

    private var aboutCard: some View {
        TailorCard(title: "About", systemImage: "info.circle.fill") {
            Text(tailor.description ?? "This tailor has no description.")
                .font(.subheadline)
                .foregroundStyle(tailor.description == nil ? .secondary : .primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var servicesCard: some View {
        if let types = tailor.types, !types.isEmpty {
            TailorCard(title: "Services", systemImage: "scissors") {
                FlowLayout(spacing: 8) {
                    ForEach(types, id: \.self) { type in
                        TagChip(text: type)
                    }
                }
            }
        }
    }

    private var messageButton: some View {
        NavigationLink {
            ChatThreadView(tailor: tailor)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("Message Tailor")
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.blue)
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }

    private var mapButton: some View {
        NavigationLink {
            TailorMapView(tailor: tailor)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "map.fill")
                Text("View on Map")
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.orange)
            )
            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }

    private func openTel(_ phone: String) {
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty, let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Reusable Tailor Components

/// Full-bleed hero image with an overlaid gradient, open-state badge, title and type.
struct TailorHeroHeader: View {
    let thumbnail: String?
    let title: String
    let type: String
    let openState: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TailorRemoteImage(url: thumbnail)
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.15), .black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                if let openState, !openState.isEmpty {
                    Text(openState)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(openStateColor))
                }

                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(type)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }

    private var openStateColor: Color {
        let state = openState?.lowercased() ?? ""
        if state.contains("closed") { return .red }
        if state.contains("open") { return .green }
        return .gray
    }
}

/// A compact stat pill (rating, reviews, price…).
struct TailorStat: View {
    let icon: String
    let value: String
    let label: String
    var tint: Color = .orange

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(tint)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

/// A generic rounded card container with an optional titled header.
struct TailorCard<Content: View>: View {
    let title: String?
    let systemImage: String?
    @ViewBuilder var content: Content

    init(
        title: String? = nil,
        systemImage: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                HStack(spacing: 8) {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .foregroundStyle(Color.orange)
                    }
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
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

/// A labelled row with a leading icon badge and optional trailing chevron.
struct TailorInfoRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    var showChevron: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(Color.orange)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.orange.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(valueColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 6)
            }
        }
    }
}

/// A small capsule tag used for service/type chips.
struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(Color.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.orange.opacity(0.12)))
    }
}

/// An expandable card listing operating hours per day.
struct TailorHoursCard: View {
    let operatingHours: GoogleMapsLocalResults.OperatingHours?
    let openState: String?
    @Binding var isExpanded: Bool

    private var rows: [(day: String, value: String)] {
        guard let operatingHours else { return [] }
        return [
            ("Monday", operatingHours.monday),
            ("Tuesday", operatingHours.tuesday),
            ("Wednesday", operatingHours.wednesday),
            ("Thursday", operatingHours.thursday),
            ("Friday", operatingHours.friday),
            ("Saturday", operatingHours.saturday),
            ("Sunday", operatingHours.sunday)
        ]
    }

    var body: some View {
        TailorCard {
            DisclosureGroup(isExpanded: $isExpanded) {
                if rows.isEmpty {
                    Text("No operating hours available.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                } else {
                    VStack(spacing: 0) {
                        ForEach(rows, id: \.day) { row in
                            HStack {
                                Text(row.day)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 12)
                                Text(row.value)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.vertical, 8)

                            if row.day != "Sunday" {
                                Divider()
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(Color.orange)
                    Text("Opening Hours")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    if let openState, !openState.isEmpty {
                        Text(openState)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .tint(.primary)
        }
    }
}

/// A responsive full-width screen header used by the Tailor list screens.
struct TailorScreenHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .foregroundStyle(Color.text)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.main)
            .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
    }
}

/// A reusable, responsive list row summarising a tailor.
struct TailorListRow: View {
    let imageURL: String?
    let title: String
    let type: String
    let rating: Float?
    let reviews: Int?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            TailorRemoteImage(url: imageURL)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(type)
                    .font(.subheadline)
                    .foregroundStyle(Color.orange)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    Label(String(format: "%.1f", rating ?? 0.0), systemImage: "star.fill")
                        .foregroundStyle(.orange)
                    Label("\(reviews ?? 0)", systemImage: "text.bubble.fill")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .labelStyle(.titleAndIcon)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

/// Async remote image with graceful loading and failure states.
struct TailorRemoteImage: View {
    let url: String?

    var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
                case .empty:
                    ZStack {
                        Rectangle().fill(Color(.secondarySystemBackground))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    ZStack {
                        Rectangle().fill(Color(.secondarySystemBackground))
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                    }
            }
        }
    }
}

/// A simple flow layout that wraps its subviews onto new lines as needed,
/// keeping chips responsive across screen sizes.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalWidth = max(totalWidth, x - spacing)
        }

        let resolvedWidth = maxWidth == .infinity ? totalWidth : min(totalWidth, maxWidth)
        return CGSize(width: resolvedWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

//#Preview {
//    TailorDetillView()
//}
