//
//  ContentView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var locationManager = LocationManager()
    @Environment(AuthViewModel.self) var viewModel
    
    var body: some View {
        NavigationStack {
//            if viewModel.isSignedIn {
//                ProfileScreen()
//            } else {
//                SignInView(showSigInScreen: .constant(true))
//            }
        }
        .environment(viewModel)
    }
}

//#Preview {
//    ContentView()
//}
