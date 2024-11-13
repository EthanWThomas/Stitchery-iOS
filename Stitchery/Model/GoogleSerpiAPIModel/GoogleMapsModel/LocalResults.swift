//
//  LocalResults.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/4/24.
//

import Foundation

struct GoogleMapsLocalResults: Decodable {
    let localResults: [LocalResults]
    
    enum CodingKeys: String, CodingKey {
        case localResults = "local_results"
    }
    
    struct LocalResults: Decodable {
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
        }
    }
}
