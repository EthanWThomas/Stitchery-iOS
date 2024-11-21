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
//    @EnvironmentObject var viewModel: AuthViewModel
    
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
//                switch selectedTab {
//                    case 2:
//                        NavigationStack {
//                            SearchTailorView(context: ModelContext(cantainer))
//                                .modelContainer(cantainer)
//                                .tag(2)
//                    }
//                    case 3:
//                        NavigationStack {
//                            MessageRoom()
//                                .tag(2)
//                        }
//                    case 4:
//                        NavigationStack {
//                            MapView()
//                                .tag(3)
//                        }
//                    default:
//                        NavigationStack {
//                            ProfileView()
//                                .tag(1)
//                        }
//                }
                ProfileScreen()
                    .tag(1)
                
                // MARK: does work?? why
                SearchTailorView(context: ModelContext(cantainer))
                    .modelContainer(cantainer)
                    .tag(2)
                
                MessageRoom()
                    .tag(3)
                
                MapView()
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
