//
//  MTPlacemark.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/4/24.
//

import Foundation
import SwiftData
import MapKit

@Model
class MTPlacemark {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var destination: Destination?
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    init(name: String, address: String, latitude: Double, longitude: Double, destination: Destination? = nil) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.destination = destination
    }
}
