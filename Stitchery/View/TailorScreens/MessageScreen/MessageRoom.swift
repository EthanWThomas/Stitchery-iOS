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
}

#Preview {
    MessageRoom()
}
