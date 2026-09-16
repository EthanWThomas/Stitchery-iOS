//
//  TailorMapDetailSheet.swift
//  Stitchery
//
//  Bottom sheet presented when a map pin is tapped. Shows the tailor's key
//  details and offers turn-by-turn directions, call, website, and favoriting.
//

import SwiftUI

struct TailorMapDetailSheet: View {

    let tailor: TailorAnnotation
    var swiftDataVM: GoogleMapVM

    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    private var isFavorite: Bool { swiftDataVM.isSaved(tailor) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    ratingRow
                    infoRows
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Tailor Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        swiftDataVM.toggleFavorite(tailor)
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(isFavorite ? Color.orange : Color.secondary)
                    }
                    .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            thumbnail
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(tailor.title)
                    .font(.title3.bold())
                    .lineLimit(2)

                if !tailor.type.isEmpty {
                    Text(tailor.type)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let openState = tailor.openState, !openState.isEmpty {
                    Text(openState)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(openState.localizedCaseInsensitiveContains("closed") ? Color.red : Color.green)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var ratingRow: some View {
        if let rating = tailor.rating {
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: starSymbol(for: index, rating: rating))
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                Text(String(format: "%.1f", rating))
                    .font(.subheadline.weight(.semibold))
                if let reviews = tailor.reviews {
                    Text("(\(reviews) reviews)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var infoRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoRow(icon: "mappin.and.ellipse", text: tailor.address)

            if let details = tailor.details, !details.isEmpty {
                infoRow(icon: "text.alignleft", text: details)
            }

            if let phone = tailor.phone, !phone.isEmpty {
                infoRow(icon: "phone.fill", text: phone)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                tailor.launchDirections()
            } label: {
                Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)

            HStack(spacing: 12) {
                if let phone = tailor.phone, let url = telURL(from: phone) {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Call", systemImage: "phone.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                }

                if let website = tailor.website, let url = URL(string: website) {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Website", systemImage: "safari.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                }
            }

            Button {
                swiftDataVM.toggleFavorite(tailor)
            } label: {
                Label(
                    isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: isFavorite ? "star.slash.fill" : "star.fill"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.bordered)
            .tint(isFavorite ? .red : .orange)
        }
        .padding(.top, 4)
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private var thumbnail: some View {
        AsyncImage(url: URL(string: tailor.thumbnail ?? "")) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .empty:
                ZStack {
                    Color.gray.opacity(0.15)
                    ProgressView()
                }
            default:
                ZStack {
                    Color.gray.opacity(0.15)
                    Image(systemName: "scissors")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func starSymbol(for index: Int, rating: Float) -> String {
        let position = Float(index) + 1
        if rating >= position { return "star.fill" }
        if rating >= position - 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }

    private func telURL(from phone: String) -> URL? {
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        return URL(string: "tel://\(digits)")
    }
}
