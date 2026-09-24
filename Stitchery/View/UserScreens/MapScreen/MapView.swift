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
    @EnvironmentObject private var searchViewModel: LocalResultViewModel

    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedTailorID: GoogleMapsLocalResults.LocalResults.ID?
    @State private var route: MKRoute?
    @State private var showDetail = false
    @State private var selectedDetail: GoogleMapsLocalResults.LocalResults?
    @State var viewModel: MapViewModel

    init(context: ModelContext) {
        self.viewModel = MapViewModel(context: context)
    }

    private var tailors: [GoogleMapsLocalResults.LocalResults] {
        (searchViewModel.searchGoogleLocalResult ?? searchViewModel.localResult)
            .filter(\.hasValidCoordinate)
    }

    private var selectedTailor: GoogleMapsLocalResults.LocalResults? {
        guard let selectedTailorID else { return nil }
        return tailors.first { $0.id == selectedTailorID }
    }

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $selectedTailorID) {
                UserAnnotation()

                ForEach(tailors) { tailor in
                    Annotation(tailor.title, coordinate: tailor.coordinate) {
                        TailorMapMarker(
                            isSelected: selectedTailorID == tailor.id,
                            title: tailor.title
                        )
                    }
                    .tag(tailor.id)
                    .annotationTitles(.hidden)
                }

                if let route {
                    MapPolyline(route.polyline)
                        .stroke(
                            Color.blue.opacity(0.85),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                        )
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .overlay(alignment: .topTrailing) {
                mapControls
            }
            .overlay(alignment: .bottom) {
                previewCard
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTailorID)
            }
            .navigationDestination(isPresented: $showDetail) {
                if let selectedDetail {
                    TailorDetailView(tailor: selectedDetail)
                }
            }
            .onChange(of: selectedTailorID) { _, _ in
                route = nil
                focusOnSelection()
            }
            .onChange(of: tailorIDs) { _, _ in
                viewModel.tailor = tailors
                fitToTailorsIfNeeded()
            }
            .onAppear {
                manager.requestWhenInUseAuthorization()
                manager.startUpdatingLocation()
                searchViewModel.loadNearbyTailorsIfNeeded()
                fitToTailorsIfNeeded()
            }
        }
    }

    private var tailorIDs: [GoogleMapsLocalResults.LocalResults.ID] {
        tailors.map(\.id)
    }

    // MARK: - Recenter Control

    private var mapControls: some View {
        VStack(spacing: 12) {
            Button(action: recenterOnUser) {
                Image(systemName: "location.fill")
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .accessibilityLabel("Recenter on Me")

            if route != nil {
                Button(action: clearRoute) {
                    Label("Clear Route", systemImage: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(.regularMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                .accessibilityLabel("Clear Route")
            }
        }
        .padding(.trailing, 16)
        .padding(.top, 12)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: route != nil)
    }

    // MARK: - Selection Preview

    @ViewBuilder
    private var previewCard: some View {
        if let selectedTailor {
            TailorMapPreviewCard(
                tailor: selectedTailor,
                distance: distanceText(to: selectedTailor),
                onClose: {
                    withAnimation {
                        selectedTailorID = nil
                        route = nil
                    }
                },
                onViewDetails: {
                    selectedDetail = selectedTailor
                    showDetail = true
                },
                onGetDirections: {
                    Task { await fetchRoute(to: selectedTailor) }
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

    /// Frames the user and every nearby tailor whenever a new result set arrives.
    private func fitToTailorsIfNeeded() {
        guard selectedTailorID == nil, !tailors.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            cameraPosition = .region(regionFittingTailors())
        }
    }

    private func regionFittingTailors() -> MKCoordinateRegion {
        var coordinates = tailors.map(\.coordinate)
        if let user = manager.location?.coordinate {
            coordinates.append(user)
        }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.45, 0.02),
                longitudeDelta: max((maxLon - minLon) * 1.45, 0.02)
            )
        )
    }

    private func fetchRoute(to tailor: GoogleMapsLocalResults.LocalResults) async {
        guard let userLocation = manager.location else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: tailor.coordinate))
        destination.name = tailor.title
        request.destination = destination
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        route = try? await directions.calculate().routes.first
        if let rect = route?.polyline.boundingMapRect {
            withAnimation(.easeInOut(duration: 0.4)) {
                cameraPosition = .rect(rect)
            }
        }
    }

    private func clearRoute() {
        withAnimation {
            route = nil
            if selectedTailor != nil {
                focusOnSelection()
            } else {
                cameraPosition = .region(regionFittingTailors())
            }
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
    var title: String = ""

    var body: some View {
        VStack(spacing: 2) {
            if isSelected, !title.isEmpty {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.regularMaterial, in: Capsule())
            }

            VStack(spacing: -2) {
                Image(systemName: "scissors")
                    .font(.system(size: isSelected ? 18 : 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: isSelected ? 42 : 34, height: isSelected ? 42 : 34)
                    .background(isSelected ? Color.orange : Color.orange.opacity(0.92), in: Circle())
                    .overlay(Circle().stroke(isSelected ? Color.white : Color.white.opacity(0.9), lineWidth: isSelected ? 3 : 2))
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.orange)
                    .offset(y: -2)
            }
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
    let onViewDetails: () -> Void
    let onGetDirections: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(tailor.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Label(String(format: "%.1f", tailor.rating ?? 0.0), systemImage: "star.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                        .labelStyle(.titleAndIcon)

                    Text(addressLine)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary, Color(.systemGray5))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }

            HStack(spacing: 10) {
                Button(action: onViewDetails) {
                    Text("View Details")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(.white)
                        .background(Color.orange, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: onGetDirections) {
                    Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(.white)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }

    private var addressLine: String {
        if let distance {
            return "\(tailor.address) · \(distance)"
        }
        return tailor.address
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

    var hasValidCoordinate: Bool {
        guard let latitude = gpsCoordinates.latitude,
              let longitude = gpsCoordinates.longitude else { return false }
        return latitude != 0 || longitude != 0
    }
}

//#Preview {
//    MapView()
//}
