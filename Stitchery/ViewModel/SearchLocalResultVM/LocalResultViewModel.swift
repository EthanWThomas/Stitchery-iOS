//
//  LocalResultViewModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import Foundation
import CoreLocation

@MainActor
final class LocalResultViewModel: ObservableObject {

    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasSearched = false

    @Published var searchText = "tailor"

    @Published private(set) var localResult = [GoogleMapsLocalResults.LocalResults]()

    private let apiManager = SerpAPIManager()

    /// Results filtered by the current search text. When the search field is
    /// empty every fetched tailor is shown.
    var searchGoogleLocalResult: [GoogleMapsLocalResults.LocalResults] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return localResult }
        return localResult.filter { result in
            result.title.range(of: trimmed, options: .caseInsensitive) != nil
        }
    }

    /// `true` when a search has completed and returned no tailors.
    var isEmpty: Bool {
        hasSearched && !isLoading && localResult.isEmpty
    }

    /// Effective query, defaulting to "tailor" so the discovery screen always
    /// has something meaningful to look for near the user.
    private var effectiveQuery: String {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "tailor" : trimmed
    }

    /// Runs a tailor search. When `coordinate` is provided the request is
    /// centred on the user's live GPS location; otherwise it falls back to a
    /// plain query search.
    func search(near coordinate: CLLocationCoordinate2D? = nil) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            hasSearched = true
        }

        do {
            let response: GoogleMapsLocalResults
            if let coordinate {
                response = try await apiManager.searchGoogleMapsLocalResult(
                    search: effectiveQuery,
                    coordinate: coordinate
                )
            } else {
                response = try await apiManager.searchGoogleMapsLocalResult(search: effectiveQuery)
            }
            localResult = response.localResults
            print("✅ Loaded \(localResult.count) tailors for query \"\(effectiveQuery)\".")
        } catch {
            print("❌ Tailor search failed: \(error)")
            errorMessage = error.localizedDescription
            localResult = []
        }
    }
}
