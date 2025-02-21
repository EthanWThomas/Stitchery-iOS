//
//  Home.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/13/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct Home: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Welcome To Stitchery")
                    .font(.largeTitle)
                    .foregroundStyle(Color.white)
                    .bold()
                    .padding()
                Text("Sign in as tailor or user")
                    .font(.subheadline)
                    .foregroundStyle(Color.white)
                
                Spacer()
                
//                NavigationLink {
//                    // TODO: Add A Tailor Sign Up View
//                } label: {
//                    Text("Tailor Sign Up")
//                        .font(.title)
//                        .foregroundStyle(Color.black)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.buttons)
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                }
                NavigationLink {
                    SignInView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Text("User Sign Up")
                        .font(.title)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.buttons)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                Spacer()
            }
            .padding()
            .background(Color.main)
            .ignoresSafeArea()
        }
    }
}

//#Preview {
//    Home()
//}
