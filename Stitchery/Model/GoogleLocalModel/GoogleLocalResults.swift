//
//  LocalResults.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/4/24.
//

import Foundation

struct GoogleLocal: Decodable {
    let localResults: [GoogleLocalResults]
    
    enum CodingKeys: String, CodingKey {
        case localResults = "local_results"
    }
    
    struct GoogleLocalResults: Decodable {
        let position: Int
        let title: String
        let reviews: Int?
        let rating: Float?
        let type: String
        let address: String
        let hours: String?
        let description: String?
        let thumbnail: String?
        let yearsInBusiness: String?
        let phone: String?
        let placeIdSearch: String?
        let price: String?
        let placeId: String
        let gpsCoordinates: GPSCoordinates
        let links: Links
        
        enum CodingKeys: String, CodingKey {
            case position
            case title
            case reviews
            case rating
            case type
            case address
            case hours
            case description
            case thumbnail = "thumbnail"
            case yearsInBusiness = "years_in_business"
            case phone
            case placeIdSearch = "place_id_search"
            case price
            case placeId = "place_id"
            case gpsCoordinates = "gps_coordinates"
            case links
        }
        
        struct Links: Decodable {
            let directions: String?
            
            enum CodingKeys: String, CodingKey {
                case directions
            }
        }
    }
}
