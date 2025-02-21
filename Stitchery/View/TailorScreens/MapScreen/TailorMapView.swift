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
//    @Environment(LocationManager.self) var locationManager
    
    @State var userLocation: CLLocation?
    @State private var showDetails = false
    @State private var mapSelection: MKMapItem?
    @State private var results = [MKMapItem]()
    @State private var tailorCameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
       ))
    
    @State private var showRoute = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var travelInterval: TimeInterval?
    @State private var transportType = MKDirectionsTransportType.automobile
    @State private var showSteps = false
    
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
//                            showRoute = true
                        }
                        .background {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 25, height: 25, alignment: .center)
                        }
                }
            if let route, routeDisplaying {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
//        .onChange(of: showRoute, { oldValue, newValue in
//            if newValue {
//                fetchRoute()
//            }
//        })
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetails = newValue != nil
        })
        .sheet(isPresented: $showDetails, content: {
            LocationDetailView(
                mapSelection: $mapSelection,
                show: $showDetails,
                showRoute: $showRoute,
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
        .task(id: mapSelection) {
            if mapSelection != nil {
                routeDisplaying = false
                showRoute = false
                route = nil
                await fetchRoute()
            }
        }

        .onChange(of: showRoute) {
            mapSelection = nil
            if showRoute {
                withAnimation {
                    routeDisplaying = true
                    if let rect = route?.polyline.boundingMapRect {
                        tailorCameraPosition = .rect(rect)
                    }
                }
            }
        }
        .task(id: transportType) {
            await fetchRoute()
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
    
//    private func fetchRoute() {
//        if let mapSelection {
//            let request = MKDirections.Request()
//            request.source = MKMapItem(placemark: MKPlacemark(
//                coordinate: CLLocationCoordinate2D(
//                    latitude: tailor.gpsCoordinates.latitude ?? 0.0,
//                    longitude: tailor.gpsCoordinates.longitude ?? 0.0)))
//            request.destination = mapSelection
//            
//            Task {
//                let result = try? await MKDirections(request: request).calculate()
//                route = result?.routes.first
//                routeDestination = mapSelection
//                
//                withAnimation(.snappy) {
//                    routeDisplaying = true
//                    showDetails = false
//                    
//                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
//                        tailorCameraPosition = .rect(rect)
//                    }
//                }
//            }
//        }
//    }
    
    func fetchRoute() async {
        if let userLocation = userLocation, let mapSelection {
            let request = MKDirections.Request()
            let sourcePlacemark = MKPlacemark(coordinate: userLocation.coordinate)
            let routeSource = MKMapItem(placemark: sourcePlacemark)
            let destinatinPlacemark = MKPlacemark(coordinate: mapSelection.placemark.coordinate)
            routeDestination = MKMapItem(placemark: destinatinPlacemark)
            routeDestination?.name = mapSelection.name
            request.source = routeSource
            request.destination = routeDestination
            request.transportType = transportType
            let directions = MKDirections(request: request)
            let result = try? await directions.calculate()
            route = result?.routes.first
            travelInterval = route?.expectedTravelTime
        }
    }
    
    func removeRoute() {
        routeDisplaying = false
        showRoute = false
        route = nil
        mapSelection = nil
        updateCameraPosition()
    }
    
}

//#Preview {
//    TailorMapView()
//}
