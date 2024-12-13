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
    
    var destination: Destination?
    var selectedPlacemark: MTPlacemark?
    
    @State private var lookaroundScene: MKLookAroundScene?
    @State var viewModel: MapViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(selectedPlacemark?.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(selectedPlacemark?.address ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.gray)
                }
            }
            if let lookaroundScene {
                LookAroundPreview(initialScene: lookaroundScene)
                    .frame(height: 200)
                    .padding()
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            HStack {
                Spacer()
                if let destination {
                    let inList = (selectedPlacemark != nil && selectedPlacemark?.destination != nil)
                    Button {
                        if let selectedPlacemark {
                            if selectedPlacemark.destination == nil {
                                destination.placemarks.append(selectedPlacemark)
                            } else {
                                selectedPlacemark.destination = nil
                            }
                            dismiss()
                        }
                    } label: {
                        Label(inList ? "Remove" : "Add", systemImage: inList ? "minus.circle" : "plus.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(inList ? .red : .green)
                }
            }
            Spacer()
        }
        .padding()
        .task(id: selectedPlacemark) {
            await fetchLookaroundPreview()
        }
//        .onAppear {
//            if let selectedPlacemark, destination != nil {
//                
//            }
//        }
    }
    
    func fetchLookaroundPreview() async {
        if let selectedPlacemark {
            lookaroundScene = nil
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: selectedPlacemark.coordinate)
            lookaroundScene = try? await lookaroundRequest.scene
        }
    }
}

//#Preview {
//    LocationDetailView()
//}
