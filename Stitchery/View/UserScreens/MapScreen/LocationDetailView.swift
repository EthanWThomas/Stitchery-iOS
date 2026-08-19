//
//  LocationDetailView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/11/24.
//

import SwiftUI
import SwiftData
import MapKit

struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @Binding var showRoute: Bool

    @State private var lookaroundScene: MKLookAroundScene?

    var tailor: GoogleMapsLocalResults.LocalResults
    var travelTime: TimeInterval?
    var travelDistance: CLLocationDistance?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            metaRow
            specialtyBadges
            previewSection
            actionButtons
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            fetchLookaroundPreview()
        }
        .onChange(of: mapSelection) { _, _ in
            fetchLookaroundPreview()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tailor.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)

                Text(tailor.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Button {
                show.toggle()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary, Color(.systemGray5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
    }

    // MARK: - Rating / Reviews / ETA

    private var metaRow: some View {
        HStack(spacing: 12) {
            Label(String(format: "%.1f", tailor.rating ?? 0.0), systemImage: "star.fill")
                .foregroundStyle(.orange)

            Text("(\(tailor.reviews ?? 0) reviews)")
                .foregroundStyle(.secondary)

            if let etaText {
                Divider().frame(height: 14)
                Label(etaText, systemImage: "car.fill")
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .font(.subheadline)
        .labelStyle(.titleAndIcon)
    }

    // MARK: - Specialty Badges

    @ViewBuilder
    private var specialtyBadges: some View {
        if let types = tailor.types, !types.isEmpty {
            FlowLayout(spacing: 8) {
                ForEach(Array(types.prefix(6)), id: \.self) { type in
                    TagChip(text: type)
                }
            }
        }
    }

    // MARK: - Look Around Preview

    @ViewBuilder
    private var previewSection: some View {
        if let scene = lookaroundScene {
            LookAroundPreview(initialScene: scene)
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            ContentUnavailableView("No preview available", systemImage: "eye.slash")
                .frame(height: 170)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
        }
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showRoute.toggle()
            } label: {
                Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.blue)
                    )
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }

            Button {
                openInMaps()
            } label: {
                Image(systemName: "map.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .frame(width: 56, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.blue.opacity(0.12))
                    )
            }
            .accessibilityLabel("Open in Maps")
        }
    }

    // MARK: - Helpers

    private var etaText: String? {
        var parts: [String] = []

        if let travelTime {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
            if let value = formatter.string(from: travelTime) {
                parts.append(value)
            }
        }

        if let travelDistance {
            let formatter = MKDistanceFormatter()
            formatter.unitStyle = .abbreviated
            parts.append(formatter.string(fromDistance: travelDistance))
        }

        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }

    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: tailor.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = tailor.title
        mapItem.openInMaps()
    }

    private func fetchLookaroundPreview() {
        if let mapSelection {
            lookaroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookaroundScene = try? await request.scene
            }
        }
    }
}

//#Preview {
//    LocationDetailView()
//}
