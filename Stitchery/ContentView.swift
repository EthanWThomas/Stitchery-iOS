//
//  ContentView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI

struct ContentView: View {
    @State var showSignIn: Bool
    
    @Environment(AuthViewModel.self) var viewModel
    
    init(showSignIn: Bool = true, showSigInScreen: Bool = true) {
        self.showSignIn = AuthManger.shared.getCurrentUser() == nil
    }
    
    var body: some View {
        if showSignIn {
            SignInView(showSigInScreen: $showSignIn)
        } else {
            NavigationStack {
                ZStack {
                    ProfileScreen()
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
