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
    
//    @State var showSignIn: Bool
//    
//    init(showSignIn: Bool = true, showSigInScreen: Bool = true) {
//        self.showSignIn = AuthManger.shared.getCurrentUser() == nil
//    }
    
    @Environment(AuthViewModel.self) var viewModel
    
    @Binding var showSigInScreen: Bool
    
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
            // MARK: here
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
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Button {
                AuthManger.shared.SignInWithGoogle { result in
                    switch result {
                        case .success(_):
//                            viewModel.isSignedIn = true
                            showSigInScreen = false
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                }
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
                RegistrationView(showSigInScreen: $showSigInScreen)
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

extension SignInView: AuthenticationFormProtocal {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

//#Preview {
//    SignInView()
//}
