//
//  SerpAPIManager.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import Foundation

struct SerpAPIManager {
    
    static var apiKey = KeyConstant.APIKey.myAPIKey
    static var apiKeyTest = "33bd9e488413b654027368e82ee533ae9b169bdf5b3d051d7bb82393b9d921e4"
    
    /// Builds a properly percent-encoded SerpAPI URL so multi-word queries
    /// (e.g. "mens tailor") don't produce a nil URL.
    static func googleMapsURL(queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents(string: "https://serpapi.com/search.json")
        components?.queryItems = queryItems
        return components?.url
    }
 
    func getGoogleLocal(search query: String) async throws -> GoogleLocal {
        guard let url = URL(string: "https://serpapi.com/search?engine=google_local&q=\(query)&google_domain=google.com&api_key=\(SerpAPIManager.apiKeyTest)")
        else { throw ResquestError.failedToCreateURL }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
            case 200: return try JSONDecoder().decode(GoogleLocal.self, from: data)
            case 400, 401: throw try JSONDecoder().decode(ErrorResponse.self, from: data)
            default: throw ResponseError.unownedErrorOccurred
        }
    }
}

enum ResquestError: Error {
    case failedToCreateURL
}

enum ResponseError: Error {
    case unownedErrorOccurred
}

// TODO: - fix this error response for SerpApi
struct ErrorResponse: Error, Decodable {
    let error: String
}
