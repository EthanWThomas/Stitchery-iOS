//
//  EditProfileView.swift
//  Stitchery
//
//  Sheet that lets the user update their profile photo, display name and
//  contact details. Styling matches the app's grouped-card / navy-gold theme.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {

    @Environment(AuthViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let user: User

    @State private var fullname: String
    @State private var email: String
    @State private var phoneNumber: String

    @State private var photoPickerItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: Image?

    @State private var isSaving = false

    init(user: User) {
        self.user = user
        _fullname = State(initialValue: user.fullname)
        _email = State(initialValue: user.email)
        _phoneNumber = State(initialValue: user.phoneNumber ?? "")
    }

    private var initials: String {
        user.initial.isEmpty ? "?" : user.initial
    }

    private var isValid: Bool {
        !fullname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    photoSection
                    detailsSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .tint(.main)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") { save() }
                            .fontWeight(.semibold)
                            .tint(.main)
                            .disabled(!isValid)
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var photoSection: some View {
        VStack(spacing: 12) {
            ProfileAvatarView(
                photoUrl: user.photoUrl,
                initials: initials,
                size: 120,
                showsEditBadge: true,
                localImage: selectedImage
            )

            PhotosPicker(selection: $photoPickerItem, matching: .images, photoLibrary: .shared()) {
                Text("Change Photo")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.main)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .onChange(of: photoPickerItem) { _, newItem in
            Task { await loadPhoto(from: newItem) }
        }
    }

    private var detailsSection: some View {
        ProfileCard("Your Details") {
            VStack(spacing: 0) {
                EditField(icon: "person", title: "Display Name",
                          text: $fullname, keyboard: .default,
                          contentType: .name)
                Divider().padding(.leading, 58)
                EditField(icon: "envelope", title: "Email",
                          text: $email, keyboard: .emailAddress,
                          contentType: .emailAddress, autocapitalize: false)
                Divider().padding(.leading, 58)
                EditField(icon: "phone", title: "Phone",
                          text: $phoneNumber, keyboard: .phonePad,
                          contentType: .telephoneNumber)
            }
        }
    }

    // MARK: - Actions

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            selectedImageData = data
            selectedImage = Image(uiImage: uiImage)
        }
    }

    private func save() {
        isSaving = true
        Task {
            var photoUrl: String? = nil
            if let data = compressedImageData() {
                photoUrl = try? await viewModel.uploadProfilePhoto(data)
            }
            await viewModel.updateProfile(
                fullname: fullname.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
                photoUrl: photoUrl
            )
            isSaving = false
            dismiss()
        }
    }

    /// Re-encode the selected photo as a reasonably sized JPEG for upload.
    private func compressedImageData() -> Data? {
        guard let selectedImageData, let uiImage = UIImage(data: selectedImageData) else { return nil }
        return uiImage.jpegData(compressionQuality: 0.7)
    }
}

// MARK: - Field

private struct EditField: View {
    let icon: String
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocapitalize: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            ProfileIconBadge(systemName: icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(title, text: $text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .textInputAutocapitalization(autocapitalize ? .words : .never)
                    .autocorrectionDisabled(!autocapitalize)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
