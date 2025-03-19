//
//  UserDetillScreen.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/20/24.
//

import SwiftUI

struct UserDetillScreen: View {
    
    let user: User
    
    @Environment(AuthViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            Text("User Detill Screen")
        }
    }
}

//#Preview {
////    UserDetillScreen()
//}
