//
//  TabNavigation.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import SwiftUI

struct TabNavigation: View {
    
    @State var selectedTab = 1
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ProfileView()
                    .tag(1)
                
                SearchTailorView()
                    .tag(2)
                
                MessageRoom()
                    .tag(3)
                
                MapView()
                    .tag(4)
            }
            .overlay(alignment: .bottom) {
                CustomTabView(tabSelection: $selectedTab)
            }
        }
    }
}

#Preview {
    TabNavigation()
}
