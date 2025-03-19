//
//  LocationDetailView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/11/24.
//

import SwiftUI
import SwiftData
import MapKit

struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var mapSelection: MKMapItem?
    @Binding var show: Bool
    @Binding var showRoute: Bool
    
    @State private var lookaroundScene: MKLookAroundScene?
    
    var tailor: GoogleMapsLocalResults.LocalResults
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(tailor.title)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text(tailor.address)
                        .font(.subheadline)
                        .foregroundStyle(Color.gray)
                        .padding(.trailing)
                }
                Spacer()
                
                Button {
                    show.toggle()
//                    mapSelection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray))
                }
            }
            
            if let scene = lookaroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            HStack(spacing: 24) {
                Button {
                    if let mapSelection {
                        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(
                            latitude: tailor.gpsCoordinates.latitude ?? 0.0,
                            longitude: tailor.gpsCoordinates.longitude ?? 0.0))
                        let mapItem = MKMapItem(placemark: placemark)
                        mapItem.openInMaps()
                        
                    }
                } label: {
                    Text("Open in Maps")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                        .frame(width: 170, height: 48)
                        .background(.green)
                        .cornerRadius(12)
                }
                
                Button {
                    showRoute.toggle()
//                    showRoute = true
                } label: {
                    Text("Get Direction")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 170, height: 40)
                        .background(.blue)
                        .cornerRadius(12)
                }
            }
        }
//        .task(id: mapSelection) {
//            fetchLookaroundPreview()
//        }
        .onAppear {
            fetchLookaroundPreview()
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            fetchLookaroundPreview()
        }
    }
    
    private func fetchLookaroundPreview() {
        if let mapSelection {
            lookaroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookaroundScene = try? await request.scene
            }
        }
    }
}

//#Preview {
//    LocationDetailView()
//}
