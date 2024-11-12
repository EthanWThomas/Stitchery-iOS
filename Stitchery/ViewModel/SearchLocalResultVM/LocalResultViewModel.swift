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
    
    @Published var localResult = [GoogleMapsLocalResults.LocalResults]()
    
    private let apiManager = SerpAPIManager()
    
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
