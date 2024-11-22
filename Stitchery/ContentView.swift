//
//  ContentView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var showHomeScreen = true
    @State private var key: String = ""
    @Environment(AuthViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            Image(systemName: "cart")
            Text("Hello World")
        }
    }
}

#Preview {
    ContentView()
}
