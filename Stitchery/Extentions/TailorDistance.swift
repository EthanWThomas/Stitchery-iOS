//
//  TailorDistance.swift
//  Stitchery
//
//  Proximity helpers for tailor discovery: turning a tailor's GPS coordinates
//  into a CLLocation, measuring the distance from the user, and formatting it
//  for display (e.g. "1.2 mi away").
//

import Foundation
import CoreLocation

extension GoogleMapsLocalResults.LocalResults {

    /// The tailor's location as a `CLLocation`, when valid coordinates exist.
    var clLocation: CLLocation? {
        guard let latitude = gpsCoordinates.latitude,
              let longitude = gpsCoordinates.longitude,
              CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        else { return nil }
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Straight-line distance in meters from `userLocation` to this tailor.
    func distance(from userLocation: CLLocation) -> CLLocationDistance? {
        guard let clLocation else { return nil }
        return userLocation.distance(from: clLocation)
    }
}

enum TailorDistanceFormatter {

    /// Formats a distance in meters as a short imperial string like "1.2 mi away"
    /// (or "450 ft away" for very short distances).
    static func string(fromMeters meters: CLLocationDistance) -> String {
        let miles = meters / 1609.344
        if miles < 0.1 {
            let feet = meters * 3.28084
            return "\(Int(feet.rounded())) ft away"
        }
        return String(format: "%.1f mi away", miles)
    }

    /// Convenience for a tailor + user location, returning `nil` when the tailor
    /// has no usable coordinates.
    static func string(for tailor: GoogleMapsLocalResults.LocalResults,
                       from userLocation: CLLocation?) -> String? {
        guard let userLocation, let meters = tailor.distance(from: userLocation) else { return nil }
        return string(fromMeters: meters)
    }
}
