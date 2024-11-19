//
//  SignInView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/13/24.
//

import SwiftUI

struct SignInView: View {
    
    @State private var email = ""
    @State private var password = ""
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 100)
                HStack(alignment: .bottom) {
                    Text("LogIn")
                        .font(.title)
                        .foregroundStyle(Color.white)
                        .bold()
                        .padding()
                    Spacer()
                }
                ZStack {
                    logIndisplayBackround
                    sigInView
                        .padding()
                }
            }
            .background(Color.main)
        }
    }
    
    private var sigInView: some View {
        VStack {
            VStack(spacing: 24) {
                InputView(
                    text: $email,
                    title: "Email",
                    placeholder: "Enter Email")
                .autocapitalization(.none)
                
                InputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Enter Password",
                    isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                Task {
                    try await viewModel.signIn(with: email, password: password)
                }
            } label: {
                HStack {
                    Text("Login")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color.siginbottons)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Button {
                // TODO: add sign in with google action
            } label: {
                HStack {
                    Text("SigIn with Google")
                }
                .foregroundStyle(.black)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color.buttons)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer(minLength: 350)
            
            NavigationLink {
                RegistrationView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                Text("Don't have an account ?")
                Text("Sign up")
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
    
    private var logIndisplayBackround: some View {
        ZStack {
            VStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 35)
                    .frame(width: 420, height: 800)
                    .foregroundStyle(Color.white)
            }
        }
    }
}

#Preview {
    SignInView()
}
