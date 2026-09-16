//
//  GoogleMapVM.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import Foundation
import SwiftData
import Observation

@Observable
class GoogleMapVM {
    
    let context: ModelContext
    
    var localResultResponseModel = [LocalResultsDataModel]()
    
    init(context: ModelContext) {
        self.context = context
        
        fetchLocalResult()
    }
    
    func fetchLocalResult() {
        do {
            self.localResultResponseModel = try context.fetch(FetchDescriptor<LocalResultsDataModel>())
        } catch {
            print("Error Fetching Local Result \(error)")
        }
    }
    
    func saveLocalResult(localResult: GoogleMapsLocalResults.LocalResults) {
        guard !isSaved(placeId: localResult.placeId, title: localResult.title) else { return }
        let resultModel = LocalResultsDataModel(
            title: localResult.title,
            placeId: localResult.placeId,
            placeIdSearch: localResult.placeIdSearch,
            reviews: localResult.reviews,
            rating: localResult.rating,
            price: localResult.price,
            type: localResult.type,
            types: localResult.types,
            address: localResult.address,
            openState: localResult.openState,
            phone: localResult.phone,
            website: localResult.website,
            itemDescription: localResult.description,
            thumbnail: localResult.thumbnail,
            latitude: localResult.gpsCoordinates.latitude,
            longitude: localResult.gpsCoordinates.longitude)
        context.insert(resultModel)
        try? context.save()
        fetchLocalResult()
    }
    
    func deleteLocalResult(localResult: GoogleMapsLocalResults.LocalResults) {
        removeSaved(placeId: localResult.placeId, title: localResult.title)
    }

    // MARK: - Favorites helpers

    /// Returns whether a tailor (matched by place id, falling back to title) is saved.
    func isSaved(placeId: String?, title: String) -> Bool {
        localResultResponseModel.contains { matches($0, placeId: placeId, title: title) }
    }

    func isSaved(_ annotation: TailorAnnotation) -> Bool {
        isSaved(placeId: annotation.placeId, title: annotation.title)
    }

    /// Persists a map annotation as a favorite, keeping its coordinate.
    func saveAnnotation(_ annotation: TailorAnnotation) {
        guard !isSaved(annotation) else { return }
        let resultModel = LocalResultsDataModel(
            title: annotation.title,
            placeId: annotation.placeId,
            rating: annotation.rating,
            type: annotation.type,
            address: annotation.address,
            openState: annotation.openState,
            phone: annotation.phone,
            website: annotation.website,
            itemDescription: annotation.details,
            thumbnail: annotation.thumbnail,
            latitude: annotation.coordinate.latitude,
            longitude: annotation.coordinate.longitude)
        resultModel.reviews = annotation.reviews
        context.insert(resultModel)
        try? context.save()
        fetchLocalResult()
    }

    func removeAnnotation(_ annotation: TailorAnnotation) {
        removeSaved(placeId: annotation.placeId, title: annotation.title)
    }

    /// Adds or removes the annotation from favorites depending on current state.
    func toggleFavorite(_ annotation: TailorAnnotation) {
        if isSaved(annotation) {
            removeAnnotation(annotation)
        } else {
            saveAnnotation(annotation)
        }
    }

    // MARK: - Private

    private func removeSaved(placeId: String?, title: String) {
        let toDelete = localResultResponseModel.filter { matches($0, placeId: placeId, title: title) }
        guard !toDelete.isEmpty else { return }
        for model in toDelete {
            context.delete(model)
        }
        try? context.save()
        fetchLocalResult()
    }

    private func matches(_ model: LocalResultsDataModel, placeId: String?, title: String) -> Bool {
        if let placeId, let modelPlaceId = model.placeId, !placeId.isEmpty {
            return modelPlaceId == placeId
        }
        return model.title == title
    }
}
