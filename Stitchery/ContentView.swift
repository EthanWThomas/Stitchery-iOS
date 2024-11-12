//
//  ContentView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var key: String = ""
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint.secondary)
            Text("Hello, world!, \n \(key)")
            
            Button("show key") {
                showKey()
            }
        }
        .padding()
    }
    
    func showKey() {
        key = """
                \(KeyConstant.APIKey.myAPIKey)
                """
    }
}

#Preview {
    ContentView()
}
