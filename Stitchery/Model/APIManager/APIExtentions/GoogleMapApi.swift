//
//  GoogleMapApi.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/6/24.
//

import Foundation
import CoreLocation

extension SerpAPIManager {
    func searchGoogleMapsLocalResult(search query: String) async throws -> GoogleMapsLocalResults {
        guard let url = URL(string: "https://serpapi.com/search.json?engine=google_maps&q=tailor&google_domain=google.com&type=search&api_key=\(SerpAPIManager.apiKeyTest)")
        else { throw ResquestError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(GoogleMapsLocalResults.self, from: data)
            case 400, 401: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    /// Fetch tailors around a specific coordinate. The coordinate is supplied by
    /// the caller (from the device's live location), keeping this networking layer
    /// fully decoupled from CoreLocation. URLComponents is used so the `ll`
    /// parameter (`@lat,long,zoom`) is percent-encoded correctly.
    func searchGoogleMapsLocalResult(
        search query: String,
        coordinate: CLLocationCoordinate2D,
        zoom: Int = 12
    ) async throws -> GoogleMapsLocalResults {
        let latitude = String(format: "%.6f", coordinate.latitude)
        let longitude = String(format: "%.6f", coordinate.longitude)

        var components = URLComponents(string: "https://serpapi.com/search.json")
        components?.queryItems = [
            URLQueryItem(name: "engine", value: "google_maps"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "ll", value: "@\(latitude),\(longitude),\(zoom)z"),
            URLQueryItem(name: "google_domain", value: "google.com"),
            URLQueryItem(name: "gl", value: "us"),
            URLQueryItem(name: "type", value: "search"),
            URLQueryItem(name: "api_key", value: SerpAPIManager.apiKeyTest)
        ]

        guard let url = components?.url
        else { throw ResquestError.failedToCreateURL }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(GoogleMapsLocalResults.self, from: data)
            case 400, 401: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    func searchGoogleMapLocalWithLocalization(
        search query: String,
        latitude: String,
        longitude: String,
        gI countries: String
    ) async throws -> GoogleMapsLocalResults {
        guard let url = URL(string: "https://serpapi.com/search.json?engine=google_maps&q=\(query)&ll=\(latitude)-\(longitude)&google_domain=google.com&gI=\(countries)&type=search&api_key=\(SerpAPIManager.apiKey)")
        else { throw ResquestError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(GoogleMapsLocalResults.self, from: data)
            case 400, 401: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
    
    func getGooglePlaceResult(search query: String, data type: String) async throws -> GoogleMapsPlaceResults {
        guard let url = URL(string: "https://serpapi.com/search?engine=google_maps&type=place&data=\(type)&api_key=\(SerpAPIManager.apiKey)")
        else { throw ResquestError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(GoogleMapsPlaceResults.self, from: data)
            case 400, 401: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
}
