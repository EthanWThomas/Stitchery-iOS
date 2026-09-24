//
//  LocalResults.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/4/24.
//

import Foundation
import CoreLocation

struct GoogleMapsLocalResults: Codable {
    let localResults: [LocalResults]
    
    enum CodingKeys: String, CodingKey {
        case localResults = "local_results"
    }
    
    struct LocalResults: Codable, Identifiable {
        let id: UUID = UUID()
        let title: String
        let placeId: String?
        let gpsCoordinates: GPSCoordinates
        let placeIdSearch: String?
        let photoslink: String?
        let reviews: Int?
        let rating: Float?
        let price: String?
        let hours: String?
        let type: String
        let types: [String]?
        let address: String
        let openState: String?
        let operatingHours: OperatingHours?
        let phone: String?
        let website: String?
        let description: String?
        let thumbnail: String?
        
        enum CodingKeys: String, CodingKey {
            case title
            case placeId = "place_id"
            case gpsCoordinates = "gps_coordinates"
            case placeIdSearch = "place_id_search"
            case photoslink = "photos_links"
            case reviews
            case rating
            case price
            case hours
            case type
            case types
            case address
            case openState = "open_state"
            case phone
            case website
            case description
            case thumbnail = "thumbnail"
            case operatingHours = "operating_hours"
        }
    }
    
    struct OperatingHours: Codable {
        var monday: String
        var tuesday: String
        var wednesday: String
        var thursday: String
        var friday: String
        var saturday: String
        var sunday: String
        
        enum CodingKeys: String, CodingKey {
            case monday
            case tuesday
            case wednesday
            case thursday
            case friday
            case saturday
            case sunday
        }
    }
}

extension GoogleMapsLocalResults.LocalResults {
    init(tailorDataModel: LocalResultsDataModel, coordinate: CLLocationCoordinate2D? = nil) {
        self.init(
            title: tailorDataModel.title,
            placeId: tailorDataModel.placeId,
            gpsCoordinates: GPSCoordinates(
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude
            ),
            placeIdSearch: tailorDataModel.placeIdSearch,
            photoslink: tailorDataModel.photoslink,
            reviews: tailorDataModel.reviews,
            rating: tailorDataModel.rating,
            price: tailorDataModel.price,
            hours: tailorDataModel.hours,
            type: tailorDataModel.type,
            types: tailorDataModel.types,
            address: tailorDataModel.address,
            openState: tailorDataModel.openState,
            operatingHours: tailorDataModel.operatingHours,
            phone: tailorDataModel.phone,
            website: tailorDataModel.website,
            description: tailorDataModel.itemDescription,
            thumbnail: tailorDataModel.thumbnail)
    }
}

