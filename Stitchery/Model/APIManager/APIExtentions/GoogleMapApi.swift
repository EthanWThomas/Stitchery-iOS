//
//  GoogleMapApi.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/6/24.
//

import Foundation

extension SerpAPIManager {
    func searchGoogleMapsLocalResult(search query: String) async throws -> GoogleMapsLocalResults {
        guard let url = URL(string: "https://serpapi.com/search.json?engine=google_maps&q=\(query)&google_domain=google.com&type=search&api_key=\(SerpAPIManager.apiKeyTest)")
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
    
    func seacrhGoogleMapLocalResultWithLatitudeAndlongitude(
        search query: String,
        latitude: String,
        longitude: String
    ) async throws -> GoogleMapsLocalResults {
        guard let url = URL(
            string: "https://serpapi.com/search.json?engine=google_maps&q=\(query)&ll=\(latitude)-\(longitude)&google_domain=google.com&type=search&api_key=\(SerpAPIManager.apiKey)")
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
