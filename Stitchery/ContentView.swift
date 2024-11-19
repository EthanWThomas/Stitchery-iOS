//
//  ContentView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var key: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            Group {
                if viewModel.userSession != nil {
                    TabNavigation()
                } else {
                    SignInView()
                }
            }
        }
    }
    
//    func showKey() {
//        key = """
//                \(KeyConstant.APIKey.myAPIKey)
//                """
//    }
}

#Preview {
    ContentView()
}
