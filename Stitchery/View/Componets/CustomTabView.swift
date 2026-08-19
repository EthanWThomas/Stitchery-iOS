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
        ("message", "Chat"),
        ("map", "Map")
    ]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<tabBarItems.count, id: \.self) { index in
                tabItem(index: index)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: tabSelection)
        .padding(6)
        .background(
            Capsule()
                .fill(Color.main)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }

    private func tabItem(index: Int) -> some View {
        let isSelected = index + 1 == tabSelection

        return Button {
            tabSelection = index + 1
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tabBarItems[index].image)
                    .symbolVariant(isSelected ? .fill : .none)
                    .font(.system(size: 20, weight: .semibold))

                Text(tabBarItems[index].title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.blue : Color.white.opacity(0.85))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(Color.white)
                        .matchedGeometryEffect(id: "SelectedTabId", in: animationNamespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tabBarItems[index].title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    CustomTabView(tabSelection: .constant(1))
        .padding(.vertical)
}
