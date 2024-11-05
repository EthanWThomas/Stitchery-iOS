//
//  GPSCoordinates.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/4/24.
//

import Foundation

struct GPSCoordinates: Decodable {
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}
