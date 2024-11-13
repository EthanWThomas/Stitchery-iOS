//
//  ProfileView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Profile View", systemImage: "person")
        }
    }
}

#Preview {
    ProfileView()
}
