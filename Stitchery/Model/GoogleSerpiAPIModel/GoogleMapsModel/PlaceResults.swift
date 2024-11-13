//
//  PlaceResults.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/4/24.
//

import Foundation

struct GoogleMapsPlaceResults: Decodable {
    let placeResult: PlaceResults
    
    enum CodingKeys: String, CodingKey {
        case placeResult = "place_results"
    }
    
    struct PlaceResults: Decodable {
        let title: String
        let gpsCoordinates: GPSCoordinates
        let thumbnail: String?
        let rating: Double?
        let reviews: Int?
        let price: String?
        let type: [String]
        let description: String
        let phone: String?
        let address: String
        let website: String?
        let openState: String?
        
        enum CodingKeys: String, CodingKey {
            case title
            case gpsCoordinates = "gps_coordinates"
            case thumbnail
            case rating
            case reviews
            case price
            case type
            case description
            case phone
            case address
            case website
            case openState = "open_state"
        }
    }
}
