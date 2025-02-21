//
//  Environment+LocationManager.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/13/24.
//

import Foundation
import SwiftUI
import CoreLocation

extension EnvironmentValues {
    @Entry var locationManager = CLLocationManager()
}

extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        

        return root
    }
}
