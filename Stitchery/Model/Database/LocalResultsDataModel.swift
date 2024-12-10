//
//  LocalResultsDataModel.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import Foundation
import SwiftData

@Model
class LocalResultsDataModel {
    var title: String
    var placeId: String?
    var placeIdSearch: String?
    var photoslink: String?
    var reviews: Int?
    var rating: Float?
    var price: String?
    var hours: String?
    var type: String
    var types: [String]?
    var address: String
    var openState: String?
    var phone: String?
    var website: String?
    var itemDescription: String?
    var thumbnail: String?
    var operatingHours: GoogleMapsLocalResults.OperatingHours?
    
    init(title: String, placeId: String? = nil, placeIdSearch: String? = nil, photoslink: String? = nil, reviews: Int? = nil, rating: Float? = nil, price: String? = nil, hours: String? = nil, type: String, types: [String]? = nil, address: String, openState: String? = nil, phone: String? = nil, website: String? = nil, itemDescription: String? = nil, thumbnail: String? = nil, operatingHours: GoogleMapsLocalResults.OperatingHours? = nil) {
        self.title = title
        self.placeId = placeId
        self.placeIdSearch = placeIdSearch
        self.photoslink = photoslink
        self.reviews = reviews
        self.rating = rating
        self.price = price
        self.hours = hours
        self.type = type
        self.types = types
        self.address = address
        self.openState = openState
        self.phone = phone
        self.website = website
        self.itemDescription = itemDescription
        self.thumbnail = thumbnail
        self.operatingHours = operatingHours
    }
}

