//
//  SavedTailorView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI
import SwiftData

struct SavedTailorView: View {
    
    @State var viewModel: GoogleMapVM
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 1) {
                titleScreen
                List {
                    ForEach(viewModel.localResultResponseModel, id: \.title) { tailor in
                        listView(
                            imageURL: tailor.thumbnail,
                            title: tailor.title,
                            type: tailor.type,
                            rating: tailor.rating,
                            reviews: tailor.reviews
                        )
                        .swipeActions {
                            Button {
                                viewModel.deleteLocalResult(localResult: tailor)
                            } label: {
                                Image(systemName: "trash.fill")
                                    .tint(Color.red)
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.fetchLocalResult()
                }
            }
        }
    }
    
    private var titleScreen: some View {
        VStack {
            Text("Saved Tailor Screen")
                .fontWeight(.semibold)
                .font(.largeTitle)
                .foregroundStyle(Color.text)
                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
        }
        .frame(width: 450, height: 40)
        .background(Color.main)
    }
    
    private func listView(imageURL: String?, title: String, type: String, rating: Float?, reviews: Int?) -> some View {
        HStack(alignment: .top) {
            disPlayUrlImage(url: imageURL)
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(type)
                        .font(.subheadline)
                        .foregroundStyle(Color.orange)
                    Text("rating: \(String(format: "%.1f", rating ?? 0.0))")
                        .font(.subheadline)
                    Text("reviews: \(reviews ?? 0)")
                        .font(.subheadline)
//                    Text(desciption ?? "Np description")
//                        .font(.subheadline)
//                        .lineLimit(2)
                }
                .padding(.leading, 10)
            }
        }
    }
    
    private func disPlayUrlImage(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                default:
                    Image(systemName: "x.circle.fill")
                        .tint(Color.red)
            }
        }
    }
}

//#Preview {
//    SavedTailorView()
//}
