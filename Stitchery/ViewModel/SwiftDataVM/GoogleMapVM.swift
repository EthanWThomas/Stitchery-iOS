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
            thumbnail: localResult.thumbnail)
        context.insert(resultModel)
        try? context.save()
        fetchLocalResult()
    }
    
    func deleteLocalResult(localResult: GoogleMapsLocalResults.LocalResults) {
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
            thumbnail: localResult.thumbnail)
        context.delete(resultModel)
        try? context.save()
    }
}
