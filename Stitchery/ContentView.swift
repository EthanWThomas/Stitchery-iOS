//
//  ContentView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI

struct ContentView: View {
    @State var showSignIn: Bool
    
//    @State var viewModel = AuthViewModel()
    
    @Environment(AuthViewModel.self) var viewModel
    
    init(showSignIn: Bool = true, showSigInScreen: Bool = true) {
        self.showSignIn = AuthManger.shared.getCurrentUser() == nil
    }
    
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
