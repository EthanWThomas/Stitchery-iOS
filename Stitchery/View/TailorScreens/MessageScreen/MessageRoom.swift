//
//  MessageRoom.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI

struct MessageRoom: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Message View", systemImage: "message")
        }
    }
    
    private var titleScreen: some View {
        VStack {
            Text("Chat Screen")
                .fontWeight(.semibold)
                .font(.largeTitle)
                .foregroundStyle(Color.text)
                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
        }
        .frame(width: 450, height: 80)
        .background(Color.main)
    }
}

#Preview {
    MessageRoom()
}
