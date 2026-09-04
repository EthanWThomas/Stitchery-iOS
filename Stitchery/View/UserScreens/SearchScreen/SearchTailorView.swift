//
//  SearchTailorView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import SwiftUI
import SwiftData
import CoreLocation

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
                if viewModel.isUsingFallbackLocation {
                    fallbackBanner
                }
                content
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                guard !hasLoaded else { return }
                hasLoaded = true
                viewModel.start()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLocationBlocked {
            locationPermissionState
        } else if viewModel.isLoading && viewModel.searchGoogleLocalResult.isEmpty {
            loadingState
        } else if viewModel.searchGoogleLocalResult.isEmpty {
            emptyState
        } else {
            tailorListView
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
            viewModel.search()
        }
    }

    private var tailorListView: some View {
        List {
            ForEach(viewModel.searchGoogleLocalResult, id: \.title) { tailor in
                NavigationLink {
                    TailorDetailView(tailor: tailor)
                } label: {
                    TailorListRow(
                        imageURL: tailor.thumbnail,
                        title: tailor.title,
                        type: tailor.type,
                        rating: tailor.rating,
                        reviews: tailor.reviews,
                        distanceText: viewModel.distanceText(for: tailor)
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
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - States

    private var fallbackBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
            Text("Showing sample results near a default location while developing.")
                .font(.caption)
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.main)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.main.opacity(0.1))
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Finding tailors near you…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 300)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "scissors")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No tailors found nearby")
                .font(.headline)
            Text("Try a different search or move to an area with more tailors.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 300)
    }

    private var locationPermissionState: some View {
        VStack(spacing: 14) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Location access needed")
                .font(.headline)
            Text("Stitchery uses your location to find tailors near you. Enable location access in Settings to see nearby results.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                openSettings()
            } label: {
                Text("Open Settings")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.text)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.main))
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: 300)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
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
