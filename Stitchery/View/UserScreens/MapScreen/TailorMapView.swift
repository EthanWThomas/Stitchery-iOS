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

    @State private var showRoute = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @State private var travelInterval: TimeInterval?
    @State private var travelDistance: CLLocationDistance?
    @State private var transportType = MKDirectionsTransportType.automobile

    var tailor: GoogleMapsLocalResults.LocalResults

    var body: some View {
        Map(position: $tailorCameraPosition) {
            UserAnnotation()

            Annotation(tailor.title, coordinate: tailor.coordinate) {
                tailorPin
            }
            .annotationTitles(.hidden)

            if let route {
                MapPolyline(route.polyline)
                    .stroke(
                        Color.blue.opacity(0.85),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                    )
            }
        }
        .overlay(alignment: .topTrailing) {
            mapControlsStack
        }
        .sheet(isPresented: $showDetails) {
            LocationDetailView(
                mapSelection: $mapSelection,
                show: $showDetails,
                showRoute: $showRoute,
                tailor: tailor,
                travelTime: travelInterval,
                travelDistance: travelDistance
            )
            .presentationDetents([.height(480)])
            .presentationBackgroundInteraction(.enabled(upThrough: .height(480)))
            .presentationCornerRadius(24)
            .presentationDragIndicator(.visible)
        }
        .task(id: showDetails) {
            if showDetails {
                await fetchETA()
            }
        }
        .task(id: showRoute) {
            if showRoute, mapSelection != nil {
                route = nil
                await fetchRoute()
                frameRoute()
            }
        }
        .task(id: transportType) {
            await fetchRoute()
        }
        .onAppear {
            updateCameraPosition()
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
    }

    // MARK: - Map Pin

    private var tailorPin: some View {
        Image(systemName: "scissors")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(Color.orange, in: Circle())
            .overlay(Circle().stroke(.white, lineWidth: 2))
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
            .onTapGesture {
                let placeMark = MKPlacemark(coordinate: tailor.coordinate)
                mapSelection = MKMapItem(placemark: placeMark)
                showDetails = true
            }
    }

    // MARK: - Floating Controls

    private var mapControlsStack: some View {
        VStack(spacing: 12) {
            Button(action: recenterOnUser) {
                Image(systemName: "location.fill")
                    .font(.headline)
                    .foregroundStyle(Color.blue)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .accessibilityLabel("Recenter on Me")

            if route != nil {
                Button(action: clearRoute) {
                    Label("Clear Route", systemImage: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(.regularMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.primary.opacity(0.08), lineWidth: 1))
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
                .accessibilityLabel("Clear Route")
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.trailing, 16)
        .padding(.top, 8)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: route != nil)
    }

    // MARK: - Camera

    private func updateCameraPosition() {
        tailorCameraPosition = .region(MKCoordinateRegion(
            center: tailor.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    private func frameRoute() {
        guard let rect = route?.polyline.boundingMapRect else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            tailorCameraPosition = .rect(rect)
        }
    }

    private func recenterOnUser() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if let coordinate = manager.location?.coordinate {
                tailorCameraPosition = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            } else {
                tailorCameraPosition = .userLocation(fallback: .automatic)
            }
        }
    }

    private func clearRoute() {
        withAnimation {
            removeRoute()
        }
    }

    // MARK: - Directions

    func fetchRoute() async {
        guard let userLocation = manager.location, let mapSelection else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: mapSelection.placemark.coordinate))
        destination.name = mapSelection.name
        routeDestination = destination
        request.destination = destination
        request.transportType = transportType

        let directions = MKDirections(request: request)
        let result = try? await directions.calculate()
        route = result?.routes.first
        travelInterval = route?.expectedTravelTime
        travelDistance = route?.distance
    }

    /// Lightweight ETA/distance lookup used to populate the preview card
    /// before the user commits to full turn-by-turn directions.
    func fetchETA() async {
        guard let userLocation = manager.location else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: tailor.coordinate))
        destination.name = tailor.title
        request.destination = destination
        request.transportType = transportType

        let directions = MKDirections(request: request)
        if let eta = try? await directions.calculateETA() {
            travelInterval = eta.expectedTravelTime
            travelDistance = eta.distance
        }
    }

    func removeRoute() {
        showRoute = false
        route = nil
        updateCameraPosition()
    }
}

//#Preview {
//    TailorMapView()
//}
