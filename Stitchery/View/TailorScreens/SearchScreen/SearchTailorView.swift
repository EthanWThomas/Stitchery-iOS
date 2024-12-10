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
//    @StateObject var locationManager = LocationManager()
    
    @State var swiftDataVM: GoogleMapVM
    
    init(context: ModelContext) {
        self.swiftDataVM = GoogleMapVM(context: context)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleScreen
                searchBar
                tailorListView
            }
        }
    }
    
    private var titleScreen: some View {
        VStack {
            Text("Search Screen")
                .fontWeight(.semibold)
                .font(.largeTitle)
                .foregroundStyle(Color.text)
                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
        }
        .frame(width: 450, height: 50)
        .background(Color.main)
    }
    
    private var searchBar: some View {
        HStack(spacing: 1) {
            ZStack {
                HStack {
//                    Spacer(minLength: 1)
                    CustomSearchBar(searchText: $viewModel.searchText)
                    Spacer(minLength: -1)
                    NavigationLink {
                        SavedTailorView(viewModel: swiftDataVM)
                    } label: {
                        Image(systemName: "text.justify")
                            .tint(Color.text)
                            .font(.largeTitle)
                    }
                    .padding()
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .stroke(Color.gray)
                            .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
                    )
                    Spacer(minLength: 15)
                }
            }
            .frame(height: 80)
            .background(
                Rectangle()
                    .fill(Color.buttons)
                    .stroke(Color.black)
            )
        }
        .onSubmit {
            viewModel.searchForLocalResult()
        }
    }
    
    private var tailorListView: some View {
        List {
            if let localResult = viewModel.searchGoogleLocalResult {
                ForEach(localResult, id: \.title) { tailor in
                    listItem(
                        imageUrl: tailor.thumbnail,
                        title: tailor.title,
                        rating: tailor.rating,
                        type: tailor.type,
                        reviews: tailor.reviews,
                        localResult: tailor
                    )
                    .swipeActions(content: {
                        Button {
                            swiftDataVM.saveLocalResult(localResult: tailor)
                        } label: {
                            Image(systemName: "heart.text.square")
                                .tint(Color.orange)
                        }
                    })
                }
            }
        }
        .onAppear {
            viewModel.searchForLocalResultWithaLocation()
        }
    }
    
    private func listItem(
        imageUrl: String?,
        title: String,
        rating: Float?,
        type: String,
        reviews: Int?,
        localResult: GoogleMapsLocalResults.LocalResults) -> some View {
        HStack(alignment: .top) {
            NavigationLink {
                TailorDetailView(tailor: localResult)
//                    .navigationBarBackButtonHidden(true)
            } label: {
                disPlayUrlImage(url: localResult.thumbnail)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(localResult.title)
                            .font(.headline)
                        Text(localResult.type)
                            .font(.subheadline)
                            .foregroundStyle(Color.orange)
                        Text("rating: \(String(format: "%.1f", localResult.rating ?? 0.0))")
                            .font(.subheadline)
                        Text("reviews: \(localResult.reviews ?? 0)")
                            .font(.subheadline)
                    }
                    .padding(.leading, 10)
                }
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
                    Image(systemName: "building")
                        .tint(Color.red)
            }
        }
    }
    
}

struct CustomSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(
                    searchText.isEmpty ? Color.secondary : Color.accentColor
                )
            TextField("Search Tailor", text: $searchText)
                .foregroundStyle(Color.accentColor)
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundStyle(Color.accentColor)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            searchText = ""
                        }
                    ,alignment: .trailing
                )
        }
        .font(.headline)
        .padding()
        .padding()
        .frame(width: 310, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .stroke(Color.gray)
                .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
        )
        .padding()
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

