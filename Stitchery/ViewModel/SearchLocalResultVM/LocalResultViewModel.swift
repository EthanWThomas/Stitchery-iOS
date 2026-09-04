//
//  LocalResultViewModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//
//  Owns tailor search & discovery. Location concerns live in `LocationManager`;
//  this view model simply observes the resolved device location and fetches
//  tailors around it, then sorts results nearest-to-furthest. Networking and
//  location updates are asynchronous and decoupled, and all UI-facing values are
//  published observable state.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class LocalResultViewModel: ObservableObject {

    // MARK: Published UI state
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""
    @Published private(set) var localResult = [GoogleMapsLocalResults.LocalResults]()
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var isUsingFallbackLocation = false

    // MARK: Collaborators
    let locationManager = LocationManager()
    private let apiManager = SerpAPIManager()
    private var cancellables = Set<AnyCancellable>()

    /// The live user location driving discovery and distance calculations.
    private(set) var userLocation: CLLocation?

    /// The last query used, so a location refresh re-runs the same search.
    private var lastQuery = "Tailor"

    /// Search-text filtered view of the (already distance-sorted) results.
    var searchGoogleLocalResult: [GoogleMapsLocalResults.LocalResults] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return localResult }
        return localResult.filter { $0.title.range(of: trimmed, options: .caseInsensitive) != nil }
    }

    /// Whether the UI should present a "location unavailable" empty state instead
    /// of results (production, permission denied/restricted, no fallback).
    var isLocationBlocked: Bool {
        locationManager.isAuthorizationBlocked && userLocation == nil
    }

    init() {
        bindLocation()
    }

    // MARK: - Lifecycle

    /// Begin the location flow. Once a coordinate resolves, `bindLocation` fetches.
    func start() {
        locationManager.start()
    }

    /// Ask for a fresh fix; the binding re-fetches when it arrives.
    func refresh() {
        locationManager.refresh()
    }

    // MARK: - Location binding

    private func bindLocation() {
        locationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in self?.authorizationStatus = status }
            .store(in: &cancellables)

        locationManager.$isUsingFallback
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFallback in self?.isUsingFallbackLocation = isFallback }
            .store(in: &cancellables)

        // Fetch whenever the resolved device location changes (real fix or, in
        // DEBUG, the fallback). We de-duplicate near-identical coordinates to
        // avoid redundant network calls.
        locationManager.$currentLocation
            .compactMap { $0 }
            .removeDuplicates { $0.distance(from: $1) < 50 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self else { return }
                self.userLocation = location
                self.fetchTailors(around: location.coordinate, query: self.lastQuery)
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetching

    /// Search using the current device location and the entered text.
    func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        lastQuery = query.isEmpty ? "Tailor" : query
        guard let coordinate = locationManager.resolvedCoordinate else {
            // No location yet — kick off the location flow; the binding will fetch.
            locationManager.start()
            return
        }
        fetchTailors(around: coordinate, query: lastQuery)
    }

    private func fetchTailors(around coordinate: CLLocationCoordinate2D, query: String) {
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.apiManager
                    .searchGoogleMapsLocalResult(search: query, coordinate: coordinate)
                    .localResults
                self.localResult = self.sortedByDistance(results)
                self.isLoading = false
            } catch {
                print("No Result Found \(error)")
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Proximity

    private func sortedByDistance(_ results: [GoogleMapsLocalResults.LocalResults]) -> [GoogleMapsLocalResults.LocalResults] {
        guard let userLocation else { return results }
        return results.sorted { lhs, rhs in
            let lhsDistance = lhs.distance(from: userLocation) ?? .greatestFiniteMagnitude
            let rhsDistance = rhs.distance(from: userLocation) ?? .greatestFiniteMagnitude
            return lhsDistance < rhsDistance
        }
    }

    /// Human-readable distance for a tailor (e.g. "1.2 mi away"), or nil.
    func distanceText(for tailor: GoogleMapsLocalResults.LocalResults) -> String? {
        TailorDistanceFormatter.string(for: tailor, from: userLocation)
    }
}
