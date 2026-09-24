//
//  LocalResultViewModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import Foundation

class LocalResultViewModel: ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?
    
    @Published var searchText = ""
    @Published var location = LocationManager()
    @Published var localResult = [GoogleMapsLocalResults.LocalResults]()

    /// Tailors with a usable coordinate, shared by the search list and the map tab.
    var nearbyTailors: [GoogleMapsLocalResults.LocalResults] {
        localResult.filter(\.hasValidCoordinate)
    }
    
    private let apiManager = SerpAPIManager()
    private var didStartNearbySearch = false
    /// Snapshot of the location-based results so Cancel can restore them after a query.
    private var nearbyBaseline = [GoogleMapsLocalResults.LocalResults]()
    
    var searchGoogleLocalResult: [GoogleMapsLocalResults.LocalResults]? {
        get { return getsearchResult() }
    }
    
    @MainActor
    func searchForLocalResult() {
        isLoading = true
        
        Task { [weak self] in
            do {
                guard let searchText = self?.searchText
                else { return }
                
                let result = try await self?.apiManager.searchGoogleMapsLocalResult(search: searchText).localResults
                self?.isLoading = false
                
                await MainActor.run { [weak self] in
                    self?.localResult = result!
                }
            } catch {
                print("No Result Found \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    /// Starts the location-based tailor search once, from whichever tab appears first.
    @MainActor
    func loadNearbyTailorsIfNeeded() {
        guard !didStartNearbySearch else { return }
        didStartNearbySearch = true
        searchForLocalResultWithaLocation()
    }

    @MainActor
    func searchForLocalResultWithaLocation() {
        isLoading = true
        
        Task { [weak self] in
            guard let self else { return }
            await self.waitForLocationFix()

            do {
                let result = try await self.apiManager
                    .seacrhGoogleMapLocalResultWithLatitudeAndlongitude(
                        search: self.searchText,
                        location: self.location
                    )
                    .localResults
                self.localResult = result
                self.nearbyBaseline = result
                self.isLoading = false
            } catch {
                print("No Result Found \(error)")
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// `requestLocation()` is one-shot and often returns after the first search call.
    private func waitForLocationFix() async {
        for _ in 0..<12 {
            if location.location != nil { return }
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
    }
    
    /// Clears the query and puts the nearby tailor list back on screen.
    @MainActor
    func cancelSearch() {
        searchText = ""
        if nearbyBaseline.isEmpty {
            didStartNearbySearch = false
            loadNearbyTailorsIfNeeded()
        } else {
            localResult = nearbyBaseline
        }
    }

    func getsearchResult() -> [GoogleMapsLocalResults.LocalResults]? {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return localResult
        } else {
            return localResult.filter { result in
                result.title.range(of: searchText, options: .caseInsensitive) != nil
            }
        }
    }
}
