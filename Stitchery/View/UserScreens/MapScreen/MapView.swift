//
//  MapView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(\.locationManager) private var manager

    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedTailorID: GoogleMapsLocalResults.LocalResults.ID?
    @State var viewModel: MapViewModel

    init(context: ModelContext) {
        self.viewModel = MapViewModel(context: context)
    }

    private var selectedTailor: GoogleMapsLocalResults.LocalResults? {
        guard let selectedTailorID else { return nil }
        return viewModel.tailor.first { $0.id == selectedTailorID }
    }

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedTailorID) {
            UserAnnotation()

            ForEach(viewModel.tailor) { tailor in
                Annotation(tailor.title, coordinate: tailor.coordinate) {
                    TailorMapMarker(isSelected: selectedTailorID == tailor.id)
                }
                .tag(tailor.id)
                .annotationTitles(.hidden)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .overlay(alignment: .topTrailing) {
            recenterButton
        }
        .overlay(alignment: .bottom) {
            previewCard
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTailorID)
        }
        .onChange(of: selectedTailorID) { _, _ in
            focusOnSelection()
        }
        .onAppear {
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
    }

    // MARK: - Recenter Control

    private var recenterButton: some View {
        Button(action: recenterOnUser) {
            Image(systemName: "location.fill")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .padding(.trailing, 16)
        .padding(.top, 12)
        .accessibilityLabel("Recenter on Me")
    }

    // MARK: - Selection Preview

    @ViewBuilder
    private var previewCard: some View {
        if let selectedTailor {
            TailorMapPreviewCard(
                tailor: selectedTailor,
                distance: distanceText(to: selectedTailor),
                onClose: {
                    withAnimation { selectedTailorID = nil }
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 110) // keep the card clear of the custom tab bar
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Camera & Location

    /// Smoothly frames the map around the currently selected tailor.
    private func focusOnSelection() {
        guard let selectedTailor else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            cameraPosition = .region(region(around: selectedTailor.coordinate))
        }
    }

    /// Centers the map on the user's current CoreLocation position.
    private func recenterOnUser() {
        withAnimation { selectedTailorID = nil }
        withAnimation(.easeInOut(duration: 0.4)) {
            if let coordinate = manager.location?.coordinate {
                cameraPosition = .region(region(around: coordinate))
            } else {
                cameraPosition = .userLocation(fallback: .automatic)
            }
        }
    }

    private func region(around coordinate: CLLocationCoordinate2D) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }

    /// Localized distance between the user and a tailor, if a fix is available.
    private func distanceText(to tailor: GoogleMapsLocalResults.LocalResults) -> String? {
        guard let userLocation = manager.location else { return nil }
        let tailorLocation = CLLocation(
            latitude: tailor.coordinate.latitude,
            longitude: tailor.coordinate.longitude
        )
        let meters = userLocation.distance(from: tailorLocation)
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: meters)
    }
}

// MARK: - Map Marker

/// A custom map pin for a tailor that emphasises the current selection.
struct TailorMapMarker: View {
    var isSelected: Bool

    var body: some View {
        VStack(spacing: -2) {
            Image(systemName: "scissors")
                .font(.system(size: isSelected ? 18 : 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: isSelected ? 42 : 34, height: isSelected ? 42 : 34)
                .background(Color.orange, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)

            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.orange)
                .offset(y: -2)
        }
        .scaleEffect(isSelected ? 1.12 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

// MARK: - Floating Preview Card

/// A floating summary card shown when a tailor pin is selected.
struct TailorMapPreviewCard: View {
    let tailor: GoogleMapsLocalResults.LocalResults
    let distance: String?
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            TailorRemoteImage(url: tailor.thumbnail)
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(tailor.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(tailor.type)
                    .font(.subheadline)
                    .foregroundStyle(Color.orange)
                    .lineLimit(1)

                HStack(spacing: 14) {
                    Label(String(format: "%.1f", tailor.rating ?? 0.0), systemImage: "star.fill")
                        .foregroundStyle(.orange)

                    if let distance {
                        Label(distance, systemImage: "location.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
                .labelStyle(.titleAndIcon)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary, Color(.systemGray5))
            }
            .buttonStyle(.plain)
            .padding(8)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Tailor Coordinate Helper

extension GoogleMapsLocalResults.LocalResults {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: gpsCoordinates.latitude ?? 0,
            longitude: gpsCoordinates.longitude ?? 0
        )
    }
}

//#Preview {
//    MapView()
//}
