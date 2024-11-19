//
//  RegistrationView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/15/24.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer(minLength: 170)
                HStack(alignment: .bottom) {
                    Text("Sign Up")
                        .font(.title)
                        .foregroundStyle(Color.white)
                        .bold()
                        .padding()
                    Spacer()
                }
                Spacer(minLength: -1)
                ZStack {
                    sigUpdisplayBackround
                    logInView
                        .padding()
                }
            }
            .background(Color.main)
        }
        
    }
    
    private var logInView: some View {
        VStack {
         
            VStack(spacing: 24) {
//                Spacer()
                InputView(
                    text: $fullname,
                    title: "User Name",
                    placeholder: "Enter Name")
                .autocapitalization(.none)
                
                InputView(
                    text: $email,
                    title: "Email",
                    placeholder: "Enter Email")
                
                InputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Enter Password",
                    isSecureField: true)
                
                InputView(
                    text: $confirmPassword,
                    title: "Confirm Password",
                    placeholder: "Enter Confirm Password",
                    isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            Button {
                Task {
                    try await viewModel.createUser(
                        withEmail: email,
                        password: password,
                        fullname: fullname)
                }
            } label: {
                HStack {
                    Text("Sign Up")
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
            
            Spacer(minLength: 185)
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("All ready have an account signIn ?")
                    Text("Sign up")
                        .fontWeight(.bold)
                }
            }
            Spacer(minLength: 150)
        }
    }
    
    private var sigUpdisplayBackround: some View {
        ZStack {
            VStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 35)
                    .frame(width: 420, height: 865)
                    .foregroundStyle(Color.white)
            }
        }
    }
}

#Preview {
    RegistrationView()
}
