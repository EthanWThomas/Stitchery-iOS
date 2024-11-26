//
//  StitcheryApp.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct StitcheryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State var viewModel = AuthViewModel()
    @State var showHomeScreen = true
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                if (AuthManger.shared.getCurrentUser() != nil) {
                    TabNavigation()
                }
            } else {
                Home()
            }
        }
        .environment(viewModel)
    }
}
