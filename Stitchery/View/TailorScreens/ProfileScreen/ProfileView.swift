//
//  ProfileView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
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
                        print("Sign out...")
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
        }
    }
}

#Preview {
    ProfileView()
}
