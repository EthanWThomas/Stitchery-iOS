//
//  MapView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Map View", systemImage: "map")
        }
    }
}

#Preview {
    MapView()
}
