//
//  MapView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI
import MapKit
import SwiftData

struct MapView: View {
    @Environment(\.locationManager) var manager

    @State private var cameraPosoition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText = ""
    @State var viewModel: MapViewModel
    
    @FocusState private var searchFieldFocus: Bool
    
    init(context: ModelContext) {
        self.viewModel = MapViewModel(context: context)
    }
    
    var body: some View {
        Map(position: $cameraPosoition) {
            UserAnnotation()
            
            ForEach(viewModel.placemarks) { placemark in
                Marker(coordinate: placemark.coordinate) {
                    Label(placemark.name, systemImage: "star")
                }
                .tint(Color.yellow)
            }
        }
        .mapControls( {
            MapUserLocationButton()
        })
        .onAppear {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    private func listTailorPlacmarks(tailor: GoogleMapsLocalResults.LocalResults) -> some View {
        TailorMapView(tailor: tailor)
    }
}

//#Preview {
//    MapView()
//}
