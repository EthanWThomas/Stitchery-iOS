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
        Group {
            if showHomeScreen {
                Home(showHomeScreen: $showHomeScreen)
            } else {
                if viewModel.userSession != nil {
                    TabNavigation()
                } else {
                    SignInView()
                }
            }
        }
    }
    
    //            Group {
    //                if showTitleScreen {
    //
    //                } else {
    //                    if viewModel.userSession != nil {
    //                        ProfileView()
    //                    } else {
    //                        SignInView()
    //                    }
    //                }
    //            }
    
    //    func showKey() {
    //        key = """
    //                \(KeyConstant.APIKey.myAPIKey)
    //                """
    //    }
}

#Preview {
    ContentView()
}
