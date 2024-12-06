//
//  SaveTailorDetailView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 12/3/24.
//

import SwiftUI
import SwiftData

struct SaveTailorDetailView: View {
    var tailor: LocalResultsDataModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var openStateExpanded = false
    
    var body: some View {
        title
        aboutView
        Spacer()
    }
    
    private var title: some View {
        VStack {
            displayImageUrl(url: tailor.thumbnail)
                .frame(width: 250, height: 250)
        }
    }
    
    private var aboutView: some View {
        VStack(alignment: .center, spacing: 15) {
            Text(tailor.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.black)
            List {
                Section("Links") {
                    Text("Address: \(tailor.address)")
                        .font(.subheadline)
                    Text("Phone Number: \(tailor.phone ?? "No Phone Number")")
                        .font(.subheadline)
                    
                    if let website = tailor.website, !website.isEmpty {
                        Link(destination: URL(string: tailor.website ?? "UnKnown")!) {
                            Text(tailor.website ?? "This Tailor has no website")
                                .underline()
                                .foregroundStyle(Color.blue)
                                .font(.subheadline)
                        }
                    } else {
                        Text("This Tailor has no website")
                            .font(.subheadline)
                            .foregroundStyle(Color.red)
                    }
                }
                
                Section("More info about \(tailor.title)") {
                    Text(tailor.itemDescription ?? "This website has no description")
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                
                Section("Type") {
                    if let types = tailor.types {
                        ForEach(types, id: \.count) { type in
                            Text(type.description)
                        }
                    }
                }
                
                Section("Pricing") {
                    Text(tailor.price ?? "This tailor has no pricing set up")
                        .font(.subheadline)
                }
                
                Section("Open Hours: \(tailor.openState ?? "This website has no Open Hours.")", isExpanded: $openStateExpanded) {
                    Text("monday: \(tailor.operatingHours?.monday ?? "No operating hours information available.")")
                    Text("tuesday: \(tailor.operatingHours?.tuesday ?? "No operating hours information available.")")
                    Text("wednesday: \(tailor.operatingHours?.wednesday ?? "No operating hours information available.")")
                    Text("thursday: \(tailor.operatingHours?.thursday ?? "No operating hours information available.")")
                    Text("friday: \(tailor.operatingHours?.friday ?? "No operating hours information available.")")
                    Text("saturday: \(tailor.operatingHours?.saturday ?? "No operating hours information available.")")
                    Text("sunday: \(tailor.operatingHours?.sunday ?? "No operating hours information available.")")
                }
            }
            .listStyle(.sidebar)
        }
    }
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "arrowshape.left")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.red)
                VStack {
                    Text("Back")
                        .foregroundStyle(Color.red)
                }
            }
        }
        .frame(width: 105, height: 35)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray)
        )
        .padding()
    }
    
    private func displayImageUrl(url: String?) -> some View {
        AsyncImage(url: URL(string: url ?? "Unknown")) { phase in
            switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                default:
                    Image(systemName: "building")
                        .tint(Color.main)
            }
        }
    }
    
    
}

//#Preview {
//    SaveTailorDetailView()
//}
