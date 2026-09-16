//
//  LocalResultViewModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import Foundation

class LocalResultViewModel: ObservableObject {
    
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    @Published var searchText = ""
    @Published var latitude = ""
    @Published var longitude = ""
    
    
    @Published var localResult = [GoogleMapsLocalResults.LocalResults]()
    
    private let apiManager = SerpAPIManager()
    
    /// The tailors to display. These are the server results as returned by the
    /// API — we intentionally do NOT re-filter them by `searchText` against the
    /// business title, since that discarded most legitimate results (e.g. a
    /// query of "tailor" would hide "John's Alterations").
    var searchGoogleLocalResult: [GoogleMapsLocalResults.LocalResults]? {
        localResult
    }
    
    @MainActor
    func searchForLocalResult() {
        performSearch(searchText)
    }
    
    /// Seeds the map/list with results on first appearance so the user isn't
    /// staring at an empty screen. Falls back to a generic "tailor" query when
    /// the search field is empty.
    @MainActor
    func loadInitialResultsIfNeeded() {
        guard localResult.isEmpty, !isLoading else { return }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        performSearch(query.isEmpty ? "tailor" : query)
    }
    
    @MainActor
    private func performSearch(_ rawQuery: String) {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        // SerpAPI rejects an empty `q`, so skip the call and just clear state.
        guard !query.isEmpty else {
            isLoading = false
            errorMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            do {
                let result = try await self?.apiManager.searchGoogleMapsLocalResult(search: query).localResults ?? []
                
                await MainActor.run { [weak self] in
                    self?.localResult = result
                    self?.isLoading = false
                }
            } catch {
                print("No Result Found \(error)")
                await MainActor.run { [weak self] in
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
    }
    
    @MainActor
    func searchForLocalResultWithaLocation() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.apiManager.seacrhGoogleMapLocalResultWithLatitudeAndlongitude(
                    search: query,
                    latitude: self.latitude,
                    longitude: self.longitude
                ).localResults
                
                await MainActor.run {
                    self.localResult = result
                    self.isLoading = false
                }
            } catch {
                print("No Result Found \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
