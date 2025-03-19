//
//  ProfileView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileScreen: View {
    
    @Environment(AuthViewModel.self) var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @State var swiftDataVM: GoogleMapVM
    
    init(context: ModelContext) {
        self.swiftDataVM = GoogleMapVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = viewModel.currentUser {
                    VStack(spacing: 0) {
                        VStack {
                            Text(user.initial)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                                .frame(width: 150, height: 150)
                                .background(Color.gray)
                                .clipShape(Circle())
                        }
                        .offset(x: 0, y: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.main)
                        .padding(.bottom, 55)
                        
                        HStack(alignment: .center) {
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding()
                            //                        Spacer()
                            Text(user.email)
                                .font(.footnote)
                                .accentColor(.gray)
                                .padding()
                        }
                        List {
                            Section("Account") {
                                Button {
                                    viewModel.signOut()
                                } label: {
                                    SettingRowView(
                                        imageName: "arrow.left.circle.fill",
                                        title: "Sign Out",
                                        tintColor: .red)
                                }
                                
//                                Button {
//                                    print("Delete account..")
//                                } label: {
//                                    SettingRowView(
//                                        imageName: "xmark.circle.fill",
//                                        title: "Delete account",
//                                        tintColor: .red)
//                                }
                            }
                            
                            Section {
                                NavigationLink {
                                    SavedTailorView(viewModel: swiftDataVM)
                                } label: {
                                    SettingRowView(
                                        imageName: "heart",
                                        title: "Favourite",
                                        tintColor: .black
                                    )
                                }
                            } header: {
                                Text("Content")
                                    .foregroundStyle(Color.black)
                            }
                            
//                            Section {
//                                Button {
//                                    // TODO: add a setting view
//                                } label: {
//                                    SettingRowView(
//                                        imageName: "list.bullet.clipboard",
//                                        title: "Setting",
//                                        tintColor: .black
//                                    )
//                                }
//                            } header: {
//                                Text("Prefernces")
//                                    .foregroundStyle(Color.black)
//                            }
                        }
                    }
                } else if let googleUser = viewModel.getGoogleUser() {
                    VStack(spacing: 0) {
                        VStack {
                            displayPhoto(photo: googleUser.photoUrl)
                                .offset(x: 0, y: 55)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.main)
                        .padding(.bottom, 55)
                        Text(googleUser.fullname)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding()
                        sectionListitem
                    }
                    .background(Color.proflielistcolor)
                }
            }
        }
    }
    
    private var sectionListitem: some View {
        List {
            Section("Account") {
                Button {
                    viewModel.signOut()
                } label: {
                    SettingRowView(
                        imageName: "arrow.left.circle.fill",
                        title: "Sign Out",
                        tintColor: .red)
                }
            }
            .foregroundStyle(Color.black)
            
            Section {
                Button {
                    // TODO: add favourite action
                } label: {
                    SettingRowView(
                        imageName: "heart",
                        title: "Favourite",
                        tintColor: .black
                    )
                }
            } header: {
                Text("Content")
                    .foregroundStyle(Color.black)
            }
            
            Section {
                Button {
                    // TODO: add a setting view
                } label: {
                    SettingRowView(
                        imageName: "list.bullet.clipboard",
                        title: "Setting",
                        tintColor: .black
                    )
                }
            } header: {
                Text("Prefernces")
                    .foregroundStyle(Color.black)
            }
        }
    }
    
    private func displayPhoto(photo url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                default:
                    Image(systemName: "person")
                        .tint(Color.black)
            }
        }
        .frame(width: 150, height: 150)
        .clipShape(Circle())
    }
}

//#Preview {
//    ProfileScreen()
//}
