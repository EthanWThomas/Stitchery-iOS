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
            VStack(spacing: 0) {
                TailorScreenHeader(title: "Saved Tailors")

                if viewModel.localResultResponseModel.isEmpty {
                    emptyState
                } else {
                    tailorList
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            viewModel.fetchLocalResult()
        }
    }

    private var tailorList: some View {
        List {
            ForEach(viewModel.localResultResponseModel, id: \.title) { tailor in
                NavigationLink {
                    SaveTailorDetailView(tailor: tailor)
                } label: {
                    TailorListRow(
                        imageURL: tailor.thumbnail,
                        title: tailor.title,
                        type: tailor.type,
                        rating: tailor.rating,
                        reviews: tailor.reviews
                    )
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.deleteLocalResult(localResult: tailor)
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No saved tailors yet")
                .font(.headline)
                .foregroundStyle(.primary)
            Text("Swipe to save tailors from the search screen and they'll appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//#Preview {
//    SavedTailorView()
//}
