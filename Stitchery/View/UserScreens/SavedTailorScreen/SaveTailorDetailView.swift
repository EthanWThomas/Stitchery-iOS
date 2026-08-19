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

    @State private var openStateExpanded = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TailorHeroHeader(
                    thumbnail: tailor.thumbnail,
                    title: tailor.title,
                    type: tailor.type,
                    openState: tailor.openState
                )

                statsRow

                contactCard

                aboutCard

                servicesCard

                TailorHoursCard(
                    operatingHours: tailor.operatingHours,
                    openState: tailor.openState,
                    isExpanded: $openStateExpanded
                )

                messageButton
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(tailor.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var messageButton: some View {
        NavigationLink {
            ChatThreadView(partner: ChatPartner(dataModel: tailor))
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("Message Tailor")
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.blue)
            )
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            TailorStat(
                icon: "star.fill",
                value: String(format: "%.1f", tailor.rating ?? 0.0),
                label: "Rating"
            )
            TailorStat(
                icon: "text.bubble.fill",
                value: "\(tailor.reviews ?? 0)",
                label: "Reviews"
            )
            if let price = tailor.price, !price.isEmpty {
                TailorStat(
                    icon: "dollarsign.circle.fill",
                    value: price,
                    label: "Price"
                )
            }
        }
    }

    private var contactCard: some View {
        TailorCard(title: "Contact", systemImage: "phone.circle.fill") {
            VStack(spacing: 14) {
                TailorInfoRow(
                    icon: "mappin.circle.fill",
                    title: "Address",
                    value: tailor.address
                )

                Divider()

                if let phone = tailor.phone, !phone.isEmpty {
                    Button {
                        openTel(phone)
                    } label: {
                        TailorInfoRow(
                            icon: "phone.fill",
                            title: "Phone",
                            value: phone,
                            valueColor: .blue,
                            showChevron: true
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    TailorInfoRow(
                        icon: "phone.fill",
                        title: "Phone",
                        value: "No phone number",
                        valueColor: .secondary
                    )
                }

                Divider()

                websiteRow
            }
        }
    }

    @ViewBuilder
    private var websiteRow: some View {
        if let website = tailor.website, !website.isEmpty, let url = URL(string: website) {
            Link(destination: url) {
                TailorInfoRow(
                    icon: "globe",
                    title: "Website",
                    value: website,
                    valueColor: .blue,
                    showChevron: true
                )
            }
            .buttonStyle(.plain)
        } else {
            TailorInfoRow(
                icon: "globe",
                title: "Website",
                value: "No website available",
                valueColor: .secondary
            )
        }
    }

    private var aboutCard: some View {
        TailorCard(title: "About", systemImage: "info.circle.fill") {
            Text(tailor.itemDescription ?? "This tailor has no description.")
                .font(.subheadline)
                .foregroundStyle(tailor.itemDescription == nil ? .secondary : .primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var servicesCard: some View {
        if let types = tailor.types, !types.isEmpty {
            TailorCard(title: "Services", systemImage: "scissors") {
                FlowLayout(spacing: 8) {
                    ForEach(types, id: \.self) { type in
                        TagChip(text: type)
                    }
                }
            }
        }
    }

    private func openTel(_ phone: String) {
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty, let url = URL(string: "tel://\(digits)") else { return }
        UIApplication.shared.open(url)
    }
}

//#Preview {
//    SaveTailorDetailView()
//}
