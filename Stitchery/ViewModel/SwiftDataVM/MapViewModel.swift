//
//  MapViewModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/11/24.
//


import Foundation
import Observation
import SwiftData
import MapKit

@MainActor
@Observable
class MapViewModel {
    let context: ModelContext
    
    var placemarks = [MTPlacemark]()
    var destination = [Destination]()
    var tailor = [GoogleMapsLocalResults.LocalResults]()
    
    init(context: ModelContext) {
        self.context = context
    }
}

// MARK: Other, Saving
extension MapViewModel {
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

// MARK: Fetching
extension MapViewModel {
    func fetchMTPlacemark() {
        do {
            self.placemarks = try context.fetch(FetchDescriptor<MTPlacemark>())
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
