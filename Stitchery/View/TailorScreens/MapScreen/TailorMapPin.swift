//
//  TailorMapPin.swift
//  Stitchery
//
//  Custom map annotation markers. Standard tailors use a scissors pin while
//  favorited tailors use a distinct gold star pin so they stand out.
//

import SwiftUI

struct TailorMapPin: View {
    let isFavorite: Bool
    let isSelected: Bool

    private var tint: Color { isFavorite ? .orange : .accentColor }
    private var symbol: String { isFavorite ? "star.fill" : "scissors" }
    private var diameter: CGFloat { isSelected ? 46 : 36 }

    var body: some View {
        VStack(spacing: -2) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.95), tint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle().stroke(.white, lineWidth: 2.5)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    .frame(width: diameter, height: diameter)

                Image(systemName: symbol)
                    .font(.system(size: isSelected ? 20 : 15, weight: .bold))
                    .foregroundStyle(.white)
            }

            PinPointer()
                .fill(tint)
                .frame(width: 14, height: 9)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

/// A small downward-pointing triangle used as the pin's tail.
struct PinPointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    HStack(spacing: 40) {
        TailorMapPin(isFavorite: false, isSelected: false)
        TailorMapPin(isFavorite: false, isSelected: true)
        TailorMapPin(isFavorite: true, isSelected: false)
        TailorMapPin(isFavorite: true, isSelected: true)
    }
    .padding()
}
