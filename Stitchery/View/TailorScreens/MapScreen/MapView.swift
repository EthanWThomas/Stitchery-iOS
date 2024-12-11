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
    let manger = CLLocationManager()
    
    @State private var cameraPostion: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText = ""
    @State private var isManualMarker = false
    @State private var selectedPlacemark: MTPlacemark?
    @State var viewModel: MapManagerViewModel
    
    @FocusState private var seacrhFielsFocus: Bool
    
    init(context: ModelContext) {
        self.viewModel = MapManagerViewModel(context: context)
    }
    
    var body: some View {
        MapReader { proxy in
            Map(position: $cameraPostion) {
                UserAnnotation()
                ForEach(viewModel.listPlacemarks) { placemark in
                    Marker(coordinate: placemark.coordinate) {
                        Label(placemark.name, systemImage: "star")
                    }
                    .tint(.yellow)
                }
            }
            .mapControls({
                MapUserLocationButton()
            })
            .onAppear {
                manger.requestWhenInUseAuthorization()
            }
        }
    }
}

//#Preview {
//    MapView()
//}
