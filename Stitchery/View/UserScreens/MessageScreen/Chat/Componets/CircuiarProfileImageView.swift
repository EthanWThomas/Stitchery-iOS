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
    let photoUrl: String?
    let size: ProfileImageSize

    init(photoUrl: String?, size: ProfileImageSize) {
        self.photoUrl = photoUrl
        self.size = size
    }

    init(user: User?, size: ProfileImageSize) {
        self.photoUrl = user?.photoUrl
        self.size = size
    }

    init(partner: ChatPartner, size: ProfileImageSize) {
        self.photoUrl = partner.photoUrl
        self.size = size
    }

    var body: some View {
        Group {
            if let photoUrl, let url = URL(string: photoUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty:
                            ProgressView()
                        default:
                            placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color(.systemGray4))
    }
}

