//
//  CustomTabView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var tabSelection: Int
    @Namespace private var animationNamespace
    
    let tabBarItems: [(image: String, title: String)] = [
        ("person", "Profile"),
        ("magnifyingglass", "Tailor"),
        ("message", "chat"),
        ("map", "Map")
    ]
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(height: 70)
                .foregroundStyle(Color.main)
                .shadow(radius: 2)
            
            HStack {
                ForEach(0..<4) { index in
                    Button {
                        tabSelection = index + 1
                    } label: {
                        VStack(spacing: 8) {
                            Spacer()
                            
                            Image(systemName: tabBarItems[index].image)
                            
                            Text(tabBarItems[index].title)
                              
                            if index + 1 == tabSelection {
                                Capsule()
                                    .frame(height: 10)
                                    .foregroundStyle(Color.blue)
                                    .matchedGeometryEffect(id: "SelectedTabId", in: animationNamespace)
                                    .offset(y: 3)
                            } else {
                                Capsule()
                                    .frame(height: 10)
                                    .foregroundStyle(Color.clear)
                                    .offset(y: 3)
                            }
                        }
                        .foregroundStyle(index + 1 == tabSelection ? Color.blue : Color.white)
                    }
                }
                .frame(height: 80)
                .clipShape(Capsule())
            }
            .frame(height: 80)
        }
        .padding(.horizontal)
    }
}

#Preview {
    CustomTabView(tabSelection: .constant(1))
        .previewLayout(.sizeThatFits)
        .padding(.vertical)
}
