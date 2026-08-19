//
//  SearchTailorView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import SwiftUI
import SwiftData

struct SearchTailorView: View {
    @StateObject private var viewModel = LocalResultViewModel()

    @State var swiftDataVM: GoogleMapVM
    @State private var hasLoaded = false

    init(context: ModelContext) {
        self.swiftDataVM = GoogleMapVM(context: context)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TailorScreenHeader(title: "Search")
                searchBar
                tailorListView
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            CustomSearchBar(searchText: $viewModel.searchText)

            NavigationLink {
                SavedTailorView(viewModel: swiftDataVM)
            } label: {
                Image(systemName: "bookmark.fill")
                    .font(.title2)
                    .foregroundStyle(Color.text)
                    .frame(width: 52, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.gray.opacity(0.4))
                    )
                    .shadow(color: .primary.opacity(0.12), radius: 6, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.buttons)
        .onSubmit {
            viewModel.searchForLocalResult()
        }
    }

    private var tailorListView: some View {
        List {
            if let localResult = viewModel.searchGoogleLocalResult {
                ForEach(localResult, id: \.title) { tailor in
                    NavigationLink {
                        TailorDetailView(tailor: tailor)
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
                        Button {
                            swiftDataVM.saveLocalResult(localResult: tailor)
                        } label: {
                            Label("Save", systemImage: "heart.text.square")
                        }
                        .tint(Color.orange)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onAppear {
            guard !hasLoaded else { return }
            hasLoaded = true
            viewModel.searchForLocalResultWithaLocation()
        }
    }
}

struct CustomSearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    searchText.isEmpty ? Color.secondary : Color.accentColor
                )

            TextField("Search tailors", text: $searchText)
                .foregroundStyle(Color.accentColor)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .font(.body)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.gray.opacity(0.4))
        )
        .shadow(color: .primary.opacity(0.12), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let catainer = try ModelContainer(for: LocalResultsDataModel.self, configurations: config)

        return SearchTailorView(context: catainer.mainContext)
            .modelContainer(catainer)
    } catch {
        fatalError("Failed to create model container")
    }
}
