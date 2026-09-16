//
//  TabNavigation.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import SwiftUI
import SwiftData

struct TabNavigation: View {
    
    @State var selectedTab = 1
    
    let cantainer: ModelContainer
    
    @StateObject private var searchVM = LocalResultViewModel()
    @State private var swiftDataVM: GoogleMapVM
    @State private var locationManager = LocationManager()
    
    init() {
        do {
            let container = try ModelContainer(for: LocalResultsDataModel.self)
            self.cantainer = container
            _swiftDataVM = State(initialValue: GoogleMapVM(context: container.mainContext))
        } catch {
            fatalError("Could not load model container.")
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ProfileView()
                    .tag(1)
                
                SearchTailorView(searchVM: searchVM, swiftDataVM: swiftDataVM)
                    .modelContainer(cantainer)
                    .tag(2)
                
                MessageRoom()
                    .tag(3)
                
                MapView(searchVM: searchVM, swiftDataVM: swiftDataVM, locationManager: locationManager)
                    .modelContainer(cantainer)
                    .tag(4)
            }
            .overlay(alignment: .bottomTrailing) {
                CustomTabView(tabSelection: $selectedTab)
            }
        }
    }
}

//#Preview {
//    TabNavigation()
//}
