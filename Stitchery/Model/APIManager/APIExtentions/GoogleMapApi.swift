//
//  GoogleMapApi.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/6/24.
//

import Foundation
import CoreLocation

extension SerpAPIManager {

    /// SerpApi's `google_maps` engine expects the location parameter `ll` in the
    /// form `@latitude,longitude,zoom` (e.g. `@40.7455096,-74.0083012,14z`).
    /// The zoom level roughly controls the search radius (3z = zoomed out,
    /// 21z = zoomed in); 14z gives a neighbourhood-sized area.
    static func makeLLParameter(
        latitude: Double,
        longitude: Double,
        zoom: Int = 14
    ) -> String {
        "@\(latitude),\(longitude),\(zoom)z"
    }

    /// Query-only search (no coordinates). Falls back to Google's default
    /// location handling for the query.
    func searchGoogleMapsLocalResult(search query: String) async throws -> GoogleMapsLocalResults {
        let url = try makeURL(queryItems: [
            URLQueryItem(name: "engine", value: "google_maps"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "google_domain", value: "google.com"),
            URLQueryItem(name: "type", value: "search"),
            URLQueryItem(name: "api_key", value: SerpAPIManager.apiKeyTest)
        ])
        return try await fetchAndDecode(GoogleMapsLocalResults.self, from: url)
    }

    /// Location-aware search that centres results on the supplied GPS
    /// coordinates using a correctly formatted `ll` parameter.
    func searchGoogleMapsLocalResult(
        search query: String,
        latitude: Double,
        longitude: Double,
        zoom: Int = 14
    ) async throws -> GoogleMapsLocalResults {
        let url = try makeURL(queryItems: [
            URLQueryItem(name: "engine", value: "google_maps"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "ll", value: SerpAPIManager.makeLLParameter(
                latitude: latitude,
                longitude: longitude,
                zoom: zoom
            )),
            URLQueryItem(name: "google_domain", value: "google.com"),
            URLQueryItem(name: "type", value: "search"),
            URLQueryItem(name: "api_key", value: SerpAPIManager.apiKeyTest)
        ])
        return try await fetchAndDecode(GoogleMapsLocalResults.self, from: url)
    }

    /// Convenience overload accepting a `CLLocationCoordinate2D` directly.
    func searchGoogleMapsLocalResult(
        search query: String,
        coordinate: CLLocationCoordinate2D,
        zoom: Int = 14
    ) async throws -> GoogleMapsLocalResults {
        try await searchGoogleMapsLocalResult(
            search: query,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            zoom: zoom
        )
    }

    /// Location-aware search additionally scoped to a country (`gl`).
    func searchGoogleMapLocalWithLocalization(
        search query: String,
        latitude: Double,
        longitude: Double,
        gl country: String,
        zoom: Int = 14
    ) async throws -> GoogleMapsLocalResults {
        let url = try makeURL(queryItems: [
            URLQueryItem(name: "engine", value: "google_maps"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "ll", value: SerpAPIManager.makeLLParameter(
                latitude: latitude,
                longitude: longitude,
                zoom: zoom
            )),
            URLQueryItem(name: "google_domain", value: "google.com"),
            URLQueryItem(name: "gl", value: country),
            URLQueryItem(name: "type", value: "search"),
            URLQueryItem(name: "api_key", value: SerpAPIManager.apiKeyTest)
        ])
        return try await fetchAndDecode(GoogleMapsLocalResults.self, from: url)
    }

    func getGooglePlaceResult(search query: String, data type: String) async throws -> GoogleMapsPlaceResults {
        let url = try makeURL(queryItems: [
            URLQueryItem(name: "engine", value: "google_maps"),
            URLQueryItem(name: "type", value: "place"),
            URLQueryItem(name: "data", value: type),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "api_key", value: SerpAPIManager.apiKeyTest)
        ])
        return try await fetchAndDecode(GoogleMapsPlaceResults.self, from: url)
    }
}
