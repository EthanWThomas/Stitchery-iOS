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
    @StateObject var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            TabNavigation()
                .environmentObject(viewModel)
//            NavigationStack {
//                Home()
//                    .task {
//                        do {
//                            try await KeyConstant.loadAPIKey()
//                        } catch {
//                            //                        debugPrint(KeyConstant.APIKeyError.self)
//                            debugPrint(error.localizedDescription)
//                        }
//                    }
//                
//            }
           
        }
    }
}
