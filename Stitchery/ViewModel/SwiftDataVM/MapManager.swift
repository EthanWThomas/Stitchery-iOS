//
//  MapManager.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/4/24.
//

import Foundation
import Observation
import SwiftData
import MapKit

@MainActor
@Observable
class MapManagerViewModel {
    let context: ModelContext
    
    var listPlacemarks = [MTPlacemark]()
    var destination = [Destination]()
    
    init(context: ModelContext) {
        self.context = context
        
        fetchMTPlacemark()
        fetchDestination()
    }
    
    @MainActor
    static func searchPlaces(_ modelContext: ModelContext, searchText: String, visibleRegion: MKCoordinateRegion?) async {
        removeSearchResults(modelContext)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        if let visibleRegion {
            request.region = visibleRegion
        }
        let searchItems = try? await MKLocalSearch(request: request).start()
        let results = searchItems?.mapItems ?? []
        results.forEach {
            let mtPlacemark = MTPlacemark(
                name: $0.placemark.name ?? "",
                address: $0.placemark.title ?? "",
                latitude: $0.placemark.coordinate.latitude,
                longitude: $0.placemark.coordinate.longitude
            )
            modelContext.insert(mtPlacemark)
        }
    }
    
    static func removeSearchResults(_ modelContext: ModelContext) {
        let searchPredicate = #Predicate<MTPlacemark> { $0.destination == nil }
        try? modelContext.delete(model: MTPlacemark.self, where: searchPredicate)
        try? modelContext.save()
    }
}

// MARK: - Fetching
extension MapManagerViewModel {
    func fetchMTPlacemark() {
        do {
            self.listPlacemarks = try context.fetch(FetchDescriptor<MTPlacemark>())
        } catch {
            print("Error fetching MTPlacemar \(error)")
        }
    }
    
    func fetchDestination() {
        do {
            self.destination = try context.fetch(FetchDescriptor<Destination>())
        } catch {
            print("Error fetching Destintion \(error)")
        }
    }
}

// MARK: Other, Saving
extension MapManagerViewModel {
    func saveMTPlacemark(mtplacemark: MTPlacemark) {
        let resultModel = MTPlacemark(
            name: mtplacemark.name,
            address: mtplacemark.address,
            latitude: mtplacemark.latitude,
            longitude: mtplacemark.longitude)
        context.insert(resultModel)
        try? context.save()
        fetchMTPlacemark()
    }
    
    func deleteMtplacemark(mtplacemark: MTPlacemark) {
        context.delete(mtplacemark)
        try? context.save()
        fetchMTPlacemark()
    }
    
    func saveDestination(destination: Destination) {
        let resultModel = Destination(name: destination.name, placemarks: destination.placemarks)
        context.insert(resultModel)
        try? context.save()
        fetchDestination()
    }
    
    func deleteDestination(destination: Destination) {
        context.delete(destination)
        try? context.save()
        fetchDestination()
    }
}
