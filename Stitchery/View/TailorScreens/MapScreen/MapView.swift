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
    
    @State var viewModel: MapManager
    
    init(context: ModelContext) {
        self.viewModel = MapManager(context: context)
    }
    
    var body: some View {
        userplacementView
    }
    
    private var userplacementView: some View {
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

//#Preview {
//    MapView()
//}
