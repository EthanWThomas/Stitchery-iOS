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
                    mapSelection = nil
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
        }
        .task(id: mapSelection) {
            fetchLookaroundPreview()
        }
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
