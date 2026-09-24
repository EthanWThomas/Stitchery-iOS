//
//  SearchTailorView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import SwiftUI
import SwiftData

struct SearchTailorView: View {
    @EnvironmentObject private var viewModel: LocalResultViewModel
    @Environment(TabBarVisibility.self) private var tabBarVisibility
    @FocusState private var isSearchFocused: Bool

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
            .toolbar(isSearchFocused ? .hidden : .visible, for: .tabBar)
            .onChange(of: isSearchFocused) { _, focused in
                withAnimation(.easeInOut) {
                    tabBarVisibility.isHidden = focused
                }
            }
            .onDisappear {
                tabBarVisibility.isHidden = false
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            CustomSearchBar(searchText: $viewModel.searchText, isFocused: $isSearchFocused) {
                viewModel.searchForLocalResult()
            }

            if showsCancel {
                Button(action: cancelSearch) {
                    Text("Cancel")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            NavigationLink {
                SavedTailorView(viewModel: swiftDataVM)
            } label: {
                Image(systemName: "bookmark.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .frame(width: 52, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(.separator))
                    )
                    .shadow(color: .primary.opacity(0.12), radius: 6, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .animation(.easeInOut, value: showsCancel)
    }

    private var showsCancel: Bool {
        isSearchFocused || !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func cancelSearch() {
        withAnimation(.easeInOut) {
            viewModel.cancelSearch()
            isSearchFocused = false
            tabBarVisibility.isHidden = false
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
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
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
            viewModel.loadNearbyTailorsIfNeeded()
        }
    }
}

struct CustomSearchBar: View {
    @Binding var searchText: String
    var isFocused: FocusState<Bool>.Binding
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(isFocused.wrappedValue ? Color.accentColor : Color.secondary)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search tailors").foregroundStyle(.secondary)
            )
            .foregroundStyle(.primary)
            .focused(isFocused)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .onSubmit {
                onSubmit()
                isFocused.wrappedValue = false
            }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    isFocused.wrappedValue = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .font(.body)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separator))
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
            .environmentObject(LocalResultViewModel())
            .environment(TabBarVisibility())
    } catch {
        fatalError("Failed to create model container")
    }
}
