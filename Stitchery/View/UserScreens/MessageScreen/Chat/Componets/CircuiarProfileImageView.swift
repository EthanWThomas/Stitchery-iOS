//
//  CircuiarProfileImageView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 3/18/25.
//

import SwiftUI

enum ProfileImageSize {
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    
    var dimension: CGFloat {
        switch self {
            case .xxSmall: return 10
            case .xSmall: return 32
            case .small: return 40
            case .medium: return 54
            case .large: return 64
            case .xLarge: return 88
        }
    }
}

struct CircuiarProfileImageView: View {
    let user: User?
    let size: ProfileImageSize
    
    var body: some View {
        if let imageUrl = user?.photoUrl {
            Image(imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .foregroundStyle(Color(.systemGray4))
        }
    }
}

