//
//  DJHomeView.swift
//  WEJAY
//
//  Created by Maya Ody-Ajike on 12/5/25.
//

import SwiftUI
import SwiftfulUI
import SwiftfulRouting
import SwiftUI
import PhotosUI

struct DJHomeView: View {
    
    @Binding var showSignUpView: Bool
    @Environment(\.router) var router
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var showCreatePartyModal: Bool = false
    
    private var sectionBackgroundColor: Color {
        Color.purple.opacity(0.12)
    }
    
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            ScrollView(.vertical) {
                LazyVStack(
                    spacing: 1,
                    pinnedViews: [.sectionHeaders],
                    content: {
                        Section {
                            VStack(spacing: 24) {

                                guideBarSection
                                    .padding(.horizontal, 16)
                                
                                startPartyTile
                                    .padding(.horizontal, 16)
                            
                                activeSessionsSection
                                
                                pastSessionsSection
                                    .padding(.horizontal, 16)
                                
                                Color.clear.frame(height: 80)
                            }
                        } header: {
                            header
                        }
                    })
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .clipped()
        }
        .task {
            await viewModel.loadInitialData()
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showCreatePartyModal) {
            if let user = viewModel.dbUser {
                CreatePartyModal(
                    showModal: $showCreatePartyModal,
                    djUser: user,
                    onPartyCreated: { party in
                        Task {
                            await viewModel.refreshActiveParties()
                        }
                    }
                )
                    .presentationDetents([.fraction(0.75), .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
            } else {
                // in case user still loading
                VStack {
                    ProgressView()
                        .tint(.purple)
                    
                    Text("Loading DJ info...")
                        .foregroundStyle(Color.appWhite)
                        .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Sections & Components
private extension DJHomeView {
    
    // MARK: Active Sessions Section
    var activeSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Sessions")
                .font(.headline)
                .foregroundStyle(Color.appWhite)
                .padding(.horizontal, 16)
            
            if viewModel.activeParties.isEmpty {
                // Empty state
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appWhite.opacity(0.05))
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(Color.appWhite.opacity(0.2))
                        )
                    
                    VStack(spacing: 8) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.title2)
                            .foregroundColor(.appWhite.opacity(0.3))
                        Text("You are not live right now.")
                            .font(.footnote)
                            .foregroundColor(.appWhite.opacity(0.5))
                    }
                }
                .padding(.horizontal, 16)
            } else {
                // Render active parties
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.activeParties) { party in
                            activePartyCard(party: party)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    
    // MARK: Past Sessions Section
    var pastSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Past Sessions")
                    .font(.headline)
                    .foregroundStyle(Color.appWhite)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to full library
                }
                .font(.caption)
                .foregroundStyle(Color.purple)
            }
            
            VStack(spacing: 12) {
                // Mock Data Rows - Replace with ForEach later
                pastSessionRow(title: "Friday Night Vibes", date: "Oct 24 • 2hr 15m", coverColor: .blue)
                pastSessionRow(title: "Chill Hop Sunday", date: "Oct 26 • 1hr 45m", coverColor: .orange)
                pastSessionRow(title: "Afrobeats Heat", date: "Nov 02 • 3hr 00m", coverColor: .green)
            }
        }
    }
    
    // Helper for a single past session row
    func pastSessionRow(title: String, date: String, coverColor: Color) -> some View {
        HStack(spacing: 16) {
            // Mini Cover Art
            RoundedRectangle(cornerRadius: 12)
                .fill(coverColor.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "music.note")
                        .foregroundStyle(.white.opacity(0.8))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appWhite)
                
                Text(date)
                    .font(.caption)
                    .foregroundStyle(Color.appWhite.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.appWhite.opacity(0.2))
        }
        .padding(12)
        .background(Color.appWhite.opacity(0.05))
        .cornerRadius(16)
    }
    
    // MARK: Start Party Tile
    var startPartyTile: some View {
        Button {
            showCreatePartyModal = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 50, height: 50)
                        .shadow(color: .purple.opacity(0.5), radius: 8, x: 0, y: 0)
                    
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start a New Party")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appWhite)
                    
                    Text("Create a room, set the vibe, and invite guests.")
                        .font(.caption)
                        .foregroundStyle(Color.appWhite.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.callout)
                    .foregroundColor(.appWhite.opacity(0.5))
            }
            .padding(20)
            .background(sectionBackgroundColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
        }
    }
     // MARK: activePartyCard
    func activePartyCard(party: Party) -> some View {
        HStack(spacing: 16) {
            // Cover
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appWhite.opacity(0.08))
                    .frame(width: 60, height: 60)
                
                if let url = party.coverImageUrl {
                    ImageLoaderView(urlString: url, resizingMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Image(systemName: "music.note.list")
                        .font(.title2)
                        .foregroundStyle(Color.appWhite.opacity(0.7))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(party.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appWhite)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if party.isActive {
                        Text("LIVE")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.85))
                            .cornerRadius(8)
                            .foregroundStyle(.white)
                    }
                }
                
                if let description = party.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.appWhite.opacity(0.7))
                        .lineLimit(2)
                } else {
                    Text("Started \(formattedRelativeDate(party.createdAt))")
                        .font(.caption)
                        .foregroundStyle(Color.appWhite.opacity(0.6))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.callout)
                .foregroundStyle(Color.appWhite.opacity(0.4))
        }
        .padding(12)
        .background(Color.appWhite.opacity(0.05))
        .cornerRadius(18)
        .onTapGesture {
            // TODO: Navigate to DJ "Now Playing" / Party control view
            print("Tapped party:", party.id)
        }
    }
    
    func formattedRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }


    
    // MARK: Header
    var header: some View {
        HStack(spacing: 16) {
            ZStack {
                if let user = viewModel.dbUser,
                   let url = user.profilePictureUrl {
                    
                    ImageLoaderView(urlString: url)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .onTapGesture {
                            router.showScreen(.push) { _ in
                                ProfileView(showSignUpView: $showSignUpView)
                            }
                        }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(Color.appWhite)
                        .onTapGesture {
                            router.showScreen(.push) { _ in
                                ProfileView(showSignUpView: $showSignUpView)
                            }
                        }
                }
            }
            .frame(width: 35, height: 35)
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(NavBarCategory.allCases, id: \.self) { category in
                        NavScrollBarCell(
                            message: category.rawValue.capitalized,
                            isSelected: category == viewModel.selectedCategory
                        )
                        .onTapGesture {
                            viewModel.selectCategory(category)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            
            Button {
                router.showScreen(.push) { _ in
                    SettingsView(showSignUpView: $showSignUpView)
                }
            } label : {
                Image(systemName: "gearshape")
                    .font(.callout)
                    .foregroundStyle(Color.appWhite)
                    .frame(minWidth: 40, minHeight: 35)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .themeColors(isSelected: false)
                    .cornerRadius(23)
            }
        }
        .padding(.vertical, 24)
        .padding(.leading, 10)
        .padding(.trailing, 8)
        .background(Color.appBlack)
    }
    
    // MARK: Guide Bar
    var guideBarSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                GuideBarCell(option: .spotify, titleOverride: viewModel.spotifyButtonDisplayTitleOverride) {
                    Task {
                        guard !viewModel.isSpotifyConnected else { return }
                        await viewModel.connectSpotify()
                    }
                }
                
                GuideBarCell(option: .appleMusic, titleOverride: viewModel.appleMusicButtonDisplayTitleOverride) {
                    Task {
                        await viewModel.connectAppleMusic()
                    }
                }
            }
            
            GuideBarCell(option: .share, titleOverride: nil) {
                // TODO: DJ-specific share flow
            }
        }
    }
}

// MARK: - Create Party Modal
struct CreatePartyModal: View {
    
    @Binding var showModal: Bool
    let djUser: DBUser
    let onPartyCreated: (Party) -> Void
    
    @State private var partyTitle: String = ""
    @State private var partyDescription: String = ""
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var coverImageData: Data?
    @State private var coverPreview: UIImage?
    @State private var isCreating: Bool = false
    
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 8) {
                    Text("Create Playlist")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appWhite)
                    
                    Text("Set the vibe for your new session.")
                        .font(.footnote)
                        .foregroundStyle(Color.appWhite.opacity(0.7))
                }
                .padding(.top, 20)
                
                // Cover + Text Inputs
                VStack(spacing: 16) {
                    
                    // Cover Picker
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 140, height: 140)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                )
                            
                            if let image = coverPreview {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundStyle(Color.purple)
                                    Text("Add Cover")
                                        .font(.caption)
                                        .foregroundStyle(Color.appWhite.opacity(0.7))
                                }
                            }
                        }
                    }
                    
                    // Text fields
                    VStack(spacing: 12) {
                        TextField("Party Name", text: $partyTitle)
                            .padding()
                            .background(Color.appWhite)
                            .cornerRadius(12)
                            .foregroundColor(.black)
                        
                        TextField("Description (Optional)", text: $partyDescription)
                            .padding()
                            .background(Color.appWhite)
                            .cornerRadius(12)
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Create button
                Button {
                    createParty()
                } label: {
                    HStack {
                        if isCreating {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Create Party")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(partyTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating
                                ? Color.gray
                                : Color.purple)
                    .cornerRadius(16)
                    .foregroundStyle(.white)
                }
                .disabled(partyTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isCreating)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.coverImageData = data
                        self.coverPreview = uiImage
                    }
                }
            }
        }
    }
    
    // MARK: - Actions

    private func createParty() {
        let trimmedTitle = partyTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = partyDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        isCreating = true
        
        Task {
            do {
                let descriptionValue = trimmedDescription.isEmpty ? nil : trimmedDescription
                
                let party = try await PartyManager.shared.createParty(
                    dj: djUser,
                    name: trimmedTitle,
                    description: descriptionValue,
                    coverImageData: coverImageData
                )
                
                await MainActor.run {
                    onPartyCreated(party)
                    isCreating = false
                    showModal = false
                }
            } catch {
                print("Error creating party:", error)
                await MainActor.run {
                    isCreating = false
                }
            }
        }
    }
}

#Preview {
    DJHomeView(showSignUpView: .constant(false))
}
