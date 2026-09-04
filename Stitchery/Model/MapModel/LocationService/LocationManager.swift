//
//  LocationManager.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/9/24.
//
//  An observable CoreLocation service that owns *all* device-location concerns
//  for tailor discovery. It requests "When In Use" authorization, publishes the
//  live device location and authorization status to observable state, and (while
//  developing) falls back to a debug coordinate so local test data still loads on
//  the Simulator.
//
//  Info.plist requirement:
//  This service relies on `NSLocationWhenInUseUsageDescription`. In this project
//  that key is supplied through the build setting
//  `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription` (with
//  `GENERATE_INFOPLIST_FILE = YES`). If you switch to a hand-managed Info.plist,
//  add the key there instead — without it CoreLocation silently refuses to
//  deliver a location.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject {

    /// Debug-only fallback coordinate. Used on the Simulator (which reports no
    /// location unless one is simulated) or when authorization is unavailable
    /// during development, so nearby test data still populates. Change this to a
    /// location you want to test against. Defaults to San Francisco, CA.
    static let debugFallbackCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    private let manager = CLLocationManager()

    /// The most recent, real device location (never the fallback).
    @Published private(set) var currentLocation: CLLocation?

    /// The latest authorization status, mirrored for the UI to react to.
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    /// True when `resolvedLocation` is currently backed by the debug fallback
    /// rather than a real GPS fix.
    @Published private(set) var isUsingFallback = false

    override init() {
        authorizationStatus = .notDetermined
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    /// The location that should drive tailor discovery: the live device location
    /// when available, otherwise the debug fallback while developing, otherwise
    /// `nil` (production with no permission → the UI shows an empty state).
    var resolvedLocation: CLLocation? {
        if let currentLocation { return currentLocation }
        #if DEBUG
        return CLLocation(latitude: Self.debugFallbackCoordinate.latitude,
                          longitude: Self.debugFallbackCoordinate.longitude)
        #else
        return nil
        #endif
    }

    var resolvedCoordinate: CLLocationCoordinate2D? { resolvedLocation?.coordinate }

    /// Whether the current authorization state blocks us from using real GPS.
    var isAuthorizationBlocked: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    // MARK: - Requests

    /// Kick off the location flow. Requests authorization when undetermined and
    /// otherwise asks for a fresh one-shot location fix.
    func start() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            applyFallbackIfDeveloping()
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }

    /// Request a single fresh location fix (used for pull-to-refresh style flows).
    func refresh() {
        guard !isAuthorizationBlocked else {
            applyFallbackIfDeveloping()
            return
        }
        manager.requestLocation()
    }

    // MARK: - Fallback

    private func applyFallbackIfDeveloping() {
        #if DEBUG
        guard currentLocation == nil else { return }
        isUsingFallback = true
        // Publish the fallback through `currentLocation` so downstream observers
        // (view models) react exactly as they would to a real fix.
        currentLocation = CLLocation(latitude: Self.debugFallbackCoordinate.latitude,
                                     longitude: Self.debugFallbackCoordinate.longitude)
        #endif
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.isUsingFallback = false
                manager.requestLocation()
            case .denied, .restricted:
                self.applyFallbackIfDeveloping()
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.isUsingFallback = false
            self.currentLocation = location
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG: LocationManager failed with error \(error.localizedDescription)")
        Task { @MainActor in
            self.applyFallbackIfDeveloping()
        }
    }
}
