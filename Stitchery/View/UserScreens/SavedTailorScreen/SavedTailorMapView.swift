//
//  SavedTailorMapView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 8/24/26.
//

import SwiftUI
import CoreLocation

/// Saved tailors are persisted without GPS coordinates, so we can't feed them
/// straight into `TailorMapView` (that would point the map at 0,0 and make the
/// route/ETA logic unreliable). This wrapper resolves a real location from the
/// saved address first, showing a loading and fallback state so the map can
/// never be presented with an invalid coordinate.
struct SavedTailorMapView: View {
    let tailor: LocalResultsDataModel

    @State private var coordinate: CLLocationCoordinate2D?
    @State private var isResolving = true

    var body: some View {
        Group {
            if let coordinate {
                TailorMapView(
                    tailor: GoogleMapsLocalResults.LocalResults(
                        tailorDataModel: tailor,
                        coordinate: coordinate
                    )
                )
            } else if isResolving {
                loadingState
            } else {
                unavailableState
            }
        }
        .navigationTitle(tailor.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await resolveCoordinate() }
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Finding location…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var unavailableState: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Location unavailable")
                .font(.headline)
            Text("We couldn't find a map location for this tailor's address.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private func resolveCoordinate() async {
        let address = tailor.address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else {
            isResolving = false
            return
        }

        let geocoder = CLGeocoder()
        let placemarks = try? await geocoder.geocodeAddressString(address)
        if let location = placemarks?.first?.location {
            coordinate = location.coordinate
        }
        isResolving = false
    }
}
