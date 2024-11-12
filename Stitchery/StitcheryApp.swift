//
//  StitcheryApp.swift
//  Stitchery
//
//  Created by Ethan Thomas on 10/31/24.
//

import SwiftUI

@main
struct StitcheryApp: App {
    var body: some Scene {
        WindowGroup {
            TabNavigation()
//                .task {
//                    do {
//                        try await KeyConstant.loadAPIKey()
//                    } catch {
////                        debugPrint(KeyConstant.APIKeyError.self)
//                        debugPrint(error.localizedDescription)
//                    }
//                }
        }
    }
}
