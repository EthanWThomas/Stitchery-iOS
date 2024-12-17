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
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(AuthViewModel.self) var viewModel
    
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
                
                ZStack(alignment: .trailing) {
                    InputView(
                        text: $confirmPassword,
                        title: "Confirm Password",
                        placeholder: "Enter Confirm Password",
                        isSecureField: true)
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.red)
                        }
                    }
                }
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
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Button {
                viewModel.signInWithGoogle { result in
                    switch result {
                        case .success(_):
                            break
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
    
    private func textIsApproiate() -> Bool {
        if password.count > 12 {
            alertTitle = "The Password may not be greater than 12 characters"
            
            showAlert.toggle()
            return false
        } else if password.count < 3 {
            alertTitle = "The Password must be at least 3 characters."
            
            showAlert.toggle()
            return false
        }
        return true
    }
    
    private func getAlert () -> Alert {
        return Alert(title: Text(alertTitle))
    }
}

extension RegistrationView: AuthenticationFormProtocal {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
    }
}

//#Preview {
//    RegistrationView()
//}
