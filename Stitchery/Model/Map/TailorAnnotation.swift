//
//  TailorAnnotation.swift
//  Stitchery
//
//  A unified, map-ready representation of a tailor. Both live search results
//  (`GoogleMapsLocalResults.LocalResults`) and persisted favorites
//  (`LocalResultsDataModel`) are projected onto this type so the map can render
//  them with a single code path.
//

import Foundation
import CoreLocation
import MapKit

struct TailorAnnotation: Identifiable, Hashable {
    let id: String
    let placeId: String?
    let title: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let rating: Float?
    let reviews: Int?
    let type: String
    let phone: String?
    let website: String?
    let thumbnail: String?
    let openState: String?
    let details: String?
    let isFavorite: Bool

    init?(localResult: GoogleMapsLocalResults.LocalResults, isFavorite: Bool) {
        guard
            let latitude = localResult.gpsCoordinates.latitude,
            let longitude = localResult.gpsCoordinates.longitude
        else { return nil }

        self.id = localResult.placeId ?? localResult.title
        self.placeId = localResult.placeId
        self.title = localResult.title
        self.address = localResult.address
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.rating = localResult.rating
        self.reviews = localResult.reviews
        self.type = localResult.type
        self.phone = localResult.phone
        self.website = localResult.website
        self.thumbnail = localResult.thumbnail
        self.openState = localResult.openState
        self.details = localResult.description
        self.isFavorite = isFavorite
    }

    init?(saved: LocalResultsDataModel) {
        guard
            let latitude = saved.latitude,
            let longitude = saved.longitude
        else { return nil }

        self.id = saved.placeId ?? saved.title
        self.placeId = saved.placeId
        self.title = saved.title
        self.address = saved.address
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.rating = saved.rating
        self.reviews = saved.reviews
        self.type = saved.type
        self.phone = saved.phone
        self.website = saved.website
        self.thumbnail = saved.thumbnail
        self.openState = saved.openState
        self.details = saved.itemDescription
        self.isFavorite = true
    }

    /// A `MKMapItem` used to launch turn-by-turn directions in Apple Maps.
    var mapItem: MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = title
        return item
    }

    /// Launches the Maps app with driving turn-by-turn directions to this tailor.
    func launchDirections() {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    static func == (lhs: TailorAnnotation, rhs: TailorAnnotation) -> Bool {
        lhs.id == rhs.id && lhs.isFavorite == rhs.isFavorite
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isFavorite)
    }
}
