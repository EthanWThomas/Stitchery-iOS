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

    /// Base host used for every SerpApi request.
    static let baseURL = "https://serpapi.com/search.json"

    /// Builds a fully percent-encoded SerpApi URL from the supplied query items.
    /// Using `URLComponents` guarantees spaces and special characters in the
    /// search term (and the `ll` coordinate string) are encoded correctly.
    func makeURL(queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(string: SerpAPIManager.baseURL) else {
            throw ResquestError.failedToCreateURL
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw ResquestError.failedToCreateURL
        }
        return url
    }

    /// Performs the request, validates the HTTP status code, and decodes the
    /// payload. Raw response bodies and decoding errors are logged to the
    /// console to make debugging failed tailor searches straightforward.
    func fetchAndDecode<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        switch statusCode {
        case 200:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                print("❌ Failed to decode \(T.self): \(error)")
                print("↳ Raw response: \(String(data: data, encoding: .utf8) ?? "<non-UTF8 data>")")
                throw error
            }
        case 400, 401:
            if let apiError = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                print("❌ SerpApi returned HTTP \(statusCode): \(apiError.error)")
                throw apiError
            }
            print("❌ SerpApi returned HTTP \(statusCode): \(String(data: data, encoding: .utf8) ?? "<non-UTF8 data>")")
            throw ResponseError.unownedErrorOccurred
        default:
            print("❌ Unexpected HTTP \(statusCode): \(String(data: data, encoding: .utf8) ?? "<non-UTF8 data>")")
            throw ResponseError.unownedErrorOccurred
        }
    }

    func getGoogleLocal(search query: String) async throws -> GoogleLocal {
        let url = try makeURL(queryItems: [
            URLQueryItem(name: "engine", value: "google_local"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "google_domain", value: "google.com"),
            URLQueryItem(name: "api_key", value: SerpAPIManager.apiKeyTest)
        ])
        return try await fetchAndDecode(GoogleLocal.self, from: url)
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
