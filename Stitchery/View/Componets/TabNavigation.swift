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
    
    init() {
        do {
            self.cantainer = try ModelContainer(for: LocalResultsDataModel.self)
        } catch {
            fatalError("Could not load model container.")
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ProfileScreen(context: cantainer.mainContext)
                    .modelContainer(cantainer)
                    .tag(1)
                
                SearchTailorView(context: cantainer.mainContext)
                    .modelContainer(cantainer)
                    .tag(2)
                
                MessageRoom()
                    .tag(3)
                
                MapView(context: cantainer.mainContext)
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
