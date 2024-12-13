//
//  TailorMapView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/13/24.
//

import SwiftUI
import MapKit

struct TailorMapView: View {
    @Environment(\.locationManager) var manager
    
    @State private var tailorCameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
       ))
    
    var tailor: GoogleMapsLocalResults.LocalResults
    
    var body: some View {
        Map(position: $tailorCameraPosition) {
            UserAnnotation()
            
            Marker(coordinate: CLLocationCoordinate2D(
                latitude: tailor.gpsCoordinates.latitude ?? 0.0,
                longitude: tailor.gpsCoordinates.longitude ?? 0.0
            )) {
                Label(tailor.title, systemImage: "person.fill")
            }
            .tint(Color.red)
        }
        .mapControls {
            MapUserLocationButton()
        }
        .onAppear {
            updateCameraPosition()
            manager.requestWhenInUseAuthorization()
        }
    }
    
    private func updateCameraPosition() {
          tailorCameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: tailor.gpsCoordinates.latitude ?? 0.0, longitude: tailor.gpsCoordinates.longitude ?? 0.0),
              span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
          ))
      }
}

//#Preview {
//    TailorMapView()
//}
