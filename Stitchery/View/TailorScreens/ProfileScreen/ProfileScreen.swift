//
//  ProfileView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI

struct ProfileScreen: View {
    
    @Environment(AuthViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Text(user.initial)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                                .frame(width: 72, height: 72)
                                .background(Color.gray)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding()
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .accentColor(.gray)
                            }
                        }
                    }
                    Section("Account") {
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingRowView(
                                imageName: "arrow.left.circle.fill",
                                title: "Sign Out",
                                tintColor: .red)
                        }
                        
                        Button {
                            print("Delete account..")
                        } label: {
                            SettingRowView(
                                imageName: "xmark.circle.fill",
                                title: "Delete account",
                                tintColor: .red)
                        }
                    }
                }
            } else if let googleUser = AuthManger.shared.getCurrentUser() {
                List {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(googleUser.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding()
                                
                                Text(googleUser.email ?? "No Email?")
                                    .font(.footnote)
                                    .accentColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var profiledisplayBackround: some View {
        ZStack {
            VStack(alignment: .center) {
                Rectangle()
                    .frame(width: 420, height: 700)
                    .foregroundStyle(Color.white)
            }
        }
    }
}

//#Preview {
//    ProfileScreen()
//}
