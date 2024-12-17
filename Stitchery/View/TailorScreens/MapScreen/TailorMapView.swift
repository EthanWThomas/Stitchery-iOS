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
    
    @State private var showDetails = false
    @State private var mapSelection: MKMapItem?
    @State private var tailorCameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
       ))
    
    var tailor: GoogleMapsLocalResults.LocalResults
    
    var body: some View {
        Map(position: $tailorCameraPosition, selection: $mapSelection) {
            
            UserAnnotation()
            Annotation(tailor.title, coordinate: CLLocationCoordinate2D(
                latitude: tailor.gpsCoordinates.latitude ?? 0.0,
                longitude: tailor.gpsCoordinates.longitude ?? 0.0)) {
                    Label(tailor.title, systemImage: "person.fill")
                        .labelStyle(.iconOnly)
                        .onTapGesture {
                            showDetails = true
                        }
                        .background {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 25, height: 25, alignment: .center)
                        }
                }
        }
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetails = newValue != nil
        })
        .sheet(isPresented: $showDetails, content: {
            LocationDetailView(
                mapSelection: $mapSelection,
                show: $showDetails,
                tailor: tailor)
            .presentationDetents([.height(340)])
            .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
            .presentationCornerRadius(12)
        })
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
            MapCompass()
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
