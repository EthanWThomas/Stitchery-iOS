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
    @StateObject private var locationManager = LocationManager()
    @State var swiftDataVM: GoogleMapVM
    
    init(context: ModelContext) {
        self.swiftDataVM = GoogleMapVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                content
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SavedTailorView(viewModel: swiftDataVM)
                    } label: {
                        Image(systemName: "square.fill.text.grid.1x2")
                            .tint(Color.black)
                    }
                }
            }
        }
        // Ask for location as soon as the screen appears.
        .onAppear {
            locationManager.requestLocation()
        }
        // Re-run the search whenever a fresh coordinate arrives so the list
        // reflects tailors near the user's live position.
        .onChange(of: locationManager.coordinate?.latitude) {
            performSearch()
        }
        // Kick off an initial search (falls back to a query-only search while
        // the first coordinate is still being resolved).
        .task {
            await viewModel.search(near: locationManager.coordinate)
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search Tailor", text: $viewModel.searchText)
                .foregroundStyle(Color.accentColor)
                .submitLabel(.search)
        }
        .font(.headline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .stroke(Color.gray)
                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
        )
        .padding()
        .onSubmit {
            performSearch()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.isEmpty {
            emptyView
        } else {
            tailorListView
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Finding tailors near you…")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") { performSearch() }
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Tailors Found", systemImage: "magnifyingglass")
        } description: {
            Text("We couldn't find any tailors near you. Try a different search term.")
        } actions: {
            Button("Retry") { performSearch() }
        }
    }
    
    private var tailorListView: some View {
        List {
            ForEach(viewModel.searchGoogleLocalResult, id: \.title) { tailor in
                listItem(
                    imageUrl: tailor.thumbnail ?? "Unknown",
                    title: tailor.title,
                    address: tailor.address,
                    description: tailor.description
                )
                .swipeActions(content: {
                    Button {
                        swiftDataVM.saveLocalResult(localResult: tailor)
                    } label: {
                        Image(systemName: "folder.fill.badge.plus")
                            .tint(Color.red)
                    }
                })
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.search(near: locationManager.coordinate)
        }
    }

    /// Launches a search on the main actor using the freshest coordinate we
    /// have (which may be `nil` until location permission is granted).
    private func performSearch() {
        Task {
            await viewModel.search(near: locationManager.coordinate)
        }
    }
    
    private func listItem(
        imageUrl: String,
        title: String,
        address: String,
        description: String?
    ) -> some View {
        HStack(alignment: .top) {
            disPlayUrlImage(url: imageUrl)
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(address)
                        .font(.subheadline)
                    Text(description ?? "No description")
                        .font(.subheadline)
                        .lineLimit(3)
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
