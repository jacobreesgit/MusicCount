import SwiftUI

public struct ContentView: View {
    @State private var service = MusicLibraryService()
    @State private var playerService = MusicPlayerService()
    @State private var selectedSong1: SongInfo?
    @State private var selectedSong2: SongInfo?
    @State private var showingComparison = false
    @State private var sortOption: SortOption = .playCountDescending

    public var body: some View {
        NavigationStack {
            Group {
                switch service.authorizationState {
                case .notDetermined:
                    unauthorizedView
                case .denied:
                    deniedView
                case .restricted:
                    restrictedView
                case .authorized:
                    authorizedView
                }
            }
            .navigationTitle("MusicCount")
            .navigationBarTitleDisplayMode(.large)
            .task {
                // Automatically request permission on first launch
                if service.authorizationState == .notDetermined {
                    await service.requestAuthorization()
                }
                // Auto-load library if already authorized (returning user)
                if service.authorizationState == .authorized {
                    if case .idle = service.loadingState {
                        await service.loadMusicLibrary()
                    }
                }
            }
            .onChange(of: service.authorizationState) { _, newState in
                // Auto-load library when permission is granted
                if newState == .authorized {
                    if case .idle = service.loadingState {
                        Task {
                            await service.loadMusicLibrary()
                        }
                    }
                }
            }
            .onChange(of: service.loadingState) { _, newState in
                // Reconcile play counts when library loads
                if case .loaded(let songs) = newState {
                    playerService.reconcilePlayCounts(currentLibrarySongs: songs)
                }
            }
            .sheet(isPresented: $showingComparison) {
                if let song1 = selectedSong1, let song2 = selectedSong2 {
                    NavigationStack {
                        ComparisonView(song1: song1, song2: song2)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Done") {
                                        showingComparison = false
                                    }
                                }
                            }
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
        }
    }

    // MARK: - Authorization Views

    private var unauthorizedView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Requesting Permission")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Please allow access to your music library when prompted.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }

    private var deniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 80))
                .foregroundStyle(.red)

            Text("Access Denied")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Music library access was denied. Please enable it in Settings > Privacy & Security > Media & Apple Music.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }

    private var restrictedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            Text("Access Restricted")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Music library access is restricted by device policies or parental controls.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }

    private var authorizedView: some View {
        Group {
            switch service.loadingState {
            case .idle, .loading:
                loadingView
            case .loaded(let songs):
                libraryView(songs: songs)
            case .error(let message):
                errorView(message: message)
            }
        }
    }

    // MARK: - Loading States

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading Music Library...")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            Text("No Songs Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("Try Again") {
                Task {
                    await service.loadMusicLibrary()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func libraryView(songs: [SongInfo]) -> some View {
        List {
            ForEach(sortOption.sorted(songs)) { song in
                SongRowView(
                    song: song,
                    selectionSlot: selectionSlot(for: song)
                )
                .accessibilityLabel("\(song.title) by \(song.artist), \(song.playCount) plays")
                .swipeActions(edge: .leading) {
                    Button {
                        if selectedSong1?.id == song.id {
                            selectedSong1 = nil
                        } else {
                            selectedSong1 = song
                        }
                    } label: {
                        if selectedSong1?.id == song.id {
                            Label("Remove", systemImage: "xmark.circle.fill")
                        } else {
                            Label("Song 1", systemImage: "1.circle.fill")
                        }
                    }
                    .tint(selectedSong1?.id == song.id ? .orange : .blue)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        if selectedSong2?.id == song.id {
                            selectedSong2 = nil
                        } else {
                            selectedSong2 = song
                        }
                    } label: {
                        if selectedSong2?.id == song.id {
                            Label("Remove", systemImage: "xmark.circle.fill")
                        } else {
                            Label("Song 2", systemImage: "2.circle.fill")
                        }
                    }
                    .tint(selectedSong2?.id == song.id ? .orange : .green)
                }
                .contextMenu {
                    Button {
                        if selectedSong1?.id == song.id {
                            selectedSong1 = nil
                        } else {
                            selectedSong1 = song
                        }
                    } label: {
                        if selectedSong1?.id == song.id {
                            Label("Deselect Song 1", systemImage: "1.circle.fill")
                        } else {
                            Label("Select as Song 1", systemImage: "1.circle.fill")
                        }
                    }

                    Button {
                        if selectedSong2?.id == song.id {
                            selectedSong2 = nil
                        } else {
                            selectedSong2 = song
                        }
                    } label: {
                        if selectedSong2?.id == song.id {
                            Label("Deselect Song 2", systemImage: "2.circle.fill")
                        } else {
                            Label("Select as Song 2", systemImage: "2.circle.fill")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            compareButton
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Label(option.displayName, systemImage: option.icon(isSelected: option == sortOption)).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }

            ToolbarItem(placement: .primaryAction) {
                clearButton
            }
        }
    }

    // MARK: - Action Buttons

    private var clearButton: some View {
        Button(role: .destructive) {
            selectedSong1 = nil
            selectedSong2 = nil
        } label: {
            Label("Clear Selection", systemImage: "xmark.circle")
                .font(.headline)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(selectedSong1 == nil && selectedSong2 == nil)
    }

    private var compareButton: some View {
        Button {
            showingComparison = true
        } label: {
            Label("Compare Songs", systemImage: "chart.bar.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(selectedSong1 == nil || selectedSong2 == nil)
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Helper Methods

    private func selectionSlot(for song: SongInfo) -> Int? {
        if selectedSong1?.id == song.id {
            return 1
        } else if selectedSong2?.id == song.id {
            return 2
        }
        return nil
    }

    public init() {}
}
