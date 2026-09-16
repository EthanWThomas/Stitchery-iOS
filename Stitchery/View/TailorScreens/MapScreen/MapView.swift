//
//  MapView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/11/24.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {

    @ObservedObject var searchVM: LocalResultViewModel
    var swiftDataVM: GoogleMapVM
    var locationManager: LocationManager

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedTailorID: String?
    @State private var detailTailor: TailorAnnotation?
    @State private var filter: MapFilter = .all
    @State private var mapStyleChoice: MapStyleChoice = .standard
    @State private var showLegend = true

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $selectedTailorID) {
                UserAnnotation()

                ForEach(displayedAnnotations) { tailor in
                    Annotation(tailor.title, coordinate: tailor.coordinate) {
                        TailorMapPin(
                            isFavorite: tailor.isFavorite,
                            isSelected: selectedTailorID == tailor.id
                        )
                        .onTapGesture {
                            selectedTailorID = tailor.id
                        }
                    }
                    .tag(tailor.id)
                    .annotationTitles(.hidden)
                }
            }
            .mapStyle(mapStyleChoice.style)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
            .safeAreaInset(edge: .top) { topControls }
            .overlay(alignment: .bottomLeading) { legendOverlay }
            .overlay(alignment: .center) { statusOverlay }
            .onChange(of: selectedTailorID) { _, newValue in
                handleSelectionChange(newValue)
            }
            .onChange(of: searchVM.searchGoogleLocalResult?.count) { _, _ in
                frameAnnotations()
            }
            .sheet(item: $detailTailor, onDismiss: { selectedTailorID = nil }) { tailor in
                TailorMapDetailSheet(tailor: tailor, swiftDataVM: swiftDataVM)
            }
            .task {
                locationManager.requestLocation()
                if searchVM.searchGoogleLocalResult?.isEmpty ?? true {
                    searchVM.searchForLocalResult()
                }
            }
        }
    }

    // MARK: - Top controls (search + filters + style)

    private var topControls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search tailors on the map", text: $searchVM.searchText)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .onSubmit { searchVM.searchForLocalResult() }
                if !searchVM.searchText.isEmpty {
                    Button {
                        searchVM.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 10) {
                Picker("Show", selection: $filter) {
                    ForEach(MapFilter.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Menu {
                    Picker("Map Style", selection: $mapStyleChoice) {
                        ForEach(MapStyleChoice.allCases) { style in
                            Label(style.title, systemImage: style.symbol).tag(style)
                        }
                    }
                    Toggle(isOn: $showLegend) {
                        Label("Legend", systemImage: "list.bullet.rectangle")
                    }
                    Button {
                        frameAnnotations(animated: true)
                    } label: {
                        Label("Fit all pins", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .padding(10)
                        .background(.regularMaterial, in: Circle())
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    // MARK: - Legend

    @ViewBuilder
    private var legendOverlay: some View {
        if showLegend {
            VStack(alignment: .leading, spacing: 8) {
                legendRow(color: .accentColor, symbol: "scissors", text: "Tailor")
                legendRow(color: .orange, symbol: "star.fill", text: "Favorite")
            }
            .padding(12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.leading)
            .padding(.bottom, 110)
            .transition(.opacity.combined(with: .move(edge: .leading)))
        }
    }

    private func legendRow(color: Color, symbol: String, text: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(color).frame(width: 22, height: 22)
                Image(systemName: symbol)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text(text)
                .font(.caption.weight(.medium))
        }
    }

    // MARK: - Status overlay (loading / empty)

    @ViewBuilder
    private var statusOverlay: some View {
        if searchVM.isLoading {
            ProgressView("Finding tailors…")
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        } else if displayedAnnotations.isEmpty {
            ContentUnavailableView(
                emptyStateTitle,
                systemImage: filter == .favorites ? "star" : "mappin.slash",
                description: Text(emptyStateMessage)
            )
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
        }
    }

    private var emptyStateTitle: String {
        filter == .favorites ? "No Favorite Tailors" : "No Tailors Found"
    }

    private var emptyStateMessage: String {
        switch filter {
        case .favorites:
            return "Tap the star on a tailor to save it here."
        case .search:
            return "Search above to discover local tailors."
        case .all:
            return "Search above or save favorites to see pins on the map."
        }
    }

    // MARK: - Annotation sources

    private var searchAnnotations: [TailorAnnotation] {
        (searchVM.searchGoogleLocalResult ?? []).compactMap { result in
            TailorAnnotation(
                localResult: result,
                isFavorite: swiftDataVM.isSaved(placeId: result.placeId, title: result.title)
            )
        }
    }

    private var favoriteAnnotations: [TailorAnnotation] {
        swiftDataVM.localResultResponseModel.compactMap { TailorAnnotation(saved: $0) }
    }

    private var displayedAnnotations: [TailorAnnotation] {
        var byId: [String: TailorAnnotation] = [:]
        switch filter {
        case .all:
            for annotation in searchAnnotations { byId[annotation.id] = annotation }
            for annotation in favoriteAnnotations { byId[annotation.id] = annotation }
        case .search:
            for annotation in searchAnnotations { byId[annotation.id] = annotation }
        case .favorites:
            for annotation in favoriteAnnotations { byId[annotation.id] = annotation }
        }
        return Array(byId.values)
    }

    // MARK: - Behaviour

    private func handleSelectionChange(_ id: String?) {
        guard let id, let tailor = displayedAnnotations.first(where: { $0.id == id }) else {
            detailTailor = nil
            return
        }
        detailTailor = tailor
        withAnimation(.easeInOut) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: tailor.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }

    private func frameAnnotations(animated: Bool = false) {
        let coordinates = displayedAnnotations.map(\.coordinate)
        guard !coordinates.isEmpty else { return }
        guard let region = MKCoordinateRegion(fitting: coordinates) else { return }
        if animated {
            withAnimation(.easeInOut) { cameraPosition = .region(region) }
        } else {
            cameraPosition = .region(region)
        }
    }
}

// MARK: - Supporting types

enum MapFilter: String, CaseIterable, Identifiable {
    case all
    case search
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .search: return "Search"
        case .favorites: return "Favorites"
        }
    }
}

enum MapStyleChoice: String, CaseIterable, Identifiable {
    case standard
    case hybrid
    case imagery

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "Standard"
        case .hybrid: return "Hybrid"
        case .imagery: return "Satellite"
        }
    }

    var symbol: String {
        switch self {
        case .standard: return "map"
        case .hybrid: return "map.fill"
        case .imagery: return "globe.americas.fill"
        }
    }

    var style: MapStyle {
        switch self {
        case .standard: return .standard
        case .hybrid: return .hybrid
        case .imagery: return .imagery
        }
    }
}

extension MKCoordinateRegion {
    /// Builds a region that comfortably fits all supplied coordinates.
    init?(fitting coordinates: [CLLocationCoordinate2D]) {
        guard let first = coordinates.first else { return nil }

        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.02),
            longitudeDelta: max((maxLon - minLon) * 1.4, 0.02)
        )
        self.init(center: center, span: span)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: LocalResultsDataModel.self, configurations: config)
        return MapView(
            searchVM: LocalResultViewModel(),
            swiftDataVM: GoogleMapVM(context: container.mainContext),
            locationManager: LocationManager()
        )
        .modelContainer(container)
    } catch {
        fatalError("Failed to create model container")
    }
}
