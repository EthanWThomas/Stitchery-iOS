//
//  DeviceLocationService.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/9/24.
//

import Combine
import CoreLocation
import CoreLocationUI

class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        requestLocation()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
}

