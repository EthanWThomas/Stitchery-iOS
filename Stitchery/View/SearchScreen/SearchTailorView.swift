//
//  SearchTailorView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/5/24.
//

import SwiftUI

struct SearchTailorView: View {
    
    @StateObject private var viewModel = LocalResultViewModel()
    
    var body: some View {
        NavigationStack {
            searchBar
            tailorListView
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search Tailor", text: $viewModel.searchText)
                .foregroundStyle(Color.accentColor)
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
            viewModel.searchForLocalResult()
        }
    }
    
    private var tailorListView: some View {
        List {
            if let localResult = viewModel.searchGoogleLocalResult {
                ForEach(localResult, id: \.title) { tailor in
                    listItem(
                        imageUrl: tailor.thumbnail ?? "Unknown",
                        title: tailor.title,
                        address: tailor.address,
                        description: tailor.description)
                }
            }
        }
        .onAppear {
            viewModel.searchForLocalResult()
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
                .frame(width: 150, height: 150)
                .cornerRadius(10)
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(address)
                        .font(.subheadline)
                    Text(description ?? "No description")
                        .font(.subheadline)
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
    SearchTailorView()
}
