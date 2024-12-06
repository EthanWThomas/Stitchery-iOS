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

//@Model
//class OperatingHours {
//    var monday: String
//    var tuesday: String
//    var wednesday: String
//    var thursday: String
//    var friday: String
//    var saturday: String
//    var sunday: String
//    
//    init(monday: String, tuesday: String, wednesday: String, thursday: String, friday: String, saturday: String, sunday: String) {
//        self.monday = monday
//        self.tuesday = tuesday
//        self.wednesday = wednesday
//        self.thursday = thursday
//        self.friday = friday
//        self.saturday = saturday
//        self.sunday = sunday
//    }
//}

// Interacts with API
//struct DataResponse: Decodable {
//    let data: String
//    let response: Int
//}
//
//@Model
//final class DataResponseModel {
//    let data: String
//    let response: Int
//    
//    init(data: String, response: Int) {
//        self.data = data
//        self.response = response
//    }
//}
//
//// Make my api request to get a DataResponse
//let dataResponse = DataResponse(data: "Hello", response: 123)
//
//// Make an instance of our Model
//let responseModel = DataResponseModel(data: dataResponse.data, response: dataResponse.response)
//
//// Save the model

