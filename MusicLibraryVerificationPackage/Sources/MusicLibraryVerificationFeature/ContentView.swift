import SwiftUI

public struct ContentView: View {
    @State private var service = MusicLibraryService()
    @State private var playerService = MusicPlayerService()
    @State private var selectedSong1: SongInfo?
    @State private var selectedSong2: SongInfo?
    @State private var showingSelection1 = false
    @State private var showingSelection2 = false
    @State private var showingComparison = false

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
            .navigationTitle("Play Count Comparison")
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
            .sheet(isPresented: $showingSelection1) {
                if case .loaded(let songs) = service.loadingState {
                    NavigationStack {
                        SongSelectionView(
                            songs: songs,
                            selectionTitle: "Select Song 1",
                            selectedSong: $selectedSong1
                        )
                    }
                }
            }
            .sheet(isPresented: $showingSelection2) {
                if case .loaded(let songs) = service.loadingState {
                    NavigationStack {
                        SongSelectionView(
                            songs: songs,
                            selectionTitle: "Select Song 2",
                            selectedSong: $selectedSong2
                        )
                    }
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
            Section {
                StatisticsView(stats: LibraryStats(songs: songs))
            }

            Section("Song Selection") {
                // Song 1 Selection Button
                Button {
                    showingSelection1 = true
                } label: {
                    SongSelectionButton(
                        label: "Song 1",
                        selectedSong: selectedSong1,
                        color: .blue
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(selectedSong1 != nil ? "Song 1: \(selectedSong1!.title) by \(selectedSong1!.artist). Tap to change selection." : "Select Song 1")

                // Song 2 Selection Button
                Button {
                    showingSelection2 = true
                } label: {
                    SongSelectionButton(
                        label: "Song 2",
                        selectedSong: selectedSong2,
                        color: .green
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(selectedSong2 != nil ? "Song 2: \(selectedSong2!.title) by \(selectedSong2!.artist). Tap to change selection." : "Select Song 2")
            }

            // Show comparison button if both songs selected
            if selectedSong1 != nil && selectedSong2 != nil {
                Section {
                    Button {
                        showingComparison = true
                    } label: {
                        Label("Compare Songs", systemImage: "chart.bar.fill")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                }
            }

            Section("All Songs (\(songs.count))") {
                ForEach(songs) { song in
                    SongRowView(song: song)
                        .accessibilityLabel("\(song.title) by \(song.artist), \(song.playCount) plays")
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            if selectedSong1 != nil || selectedSong2 != nil {
                ToolbarItem(placement: .secondaryAction) {
                    Button("Clear Selection") {
                        selectedSong1 = nil
                        selectedSong2 = nil
                    }
                }
            }
        }
    }

    public init() {}
}

// MARK: - Song Selection Button

private struct SongSelectionButton: View {
    let label: String
    let selectedSong: SongInfo?
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Color badge
            Circle()
                .fill(color.gradient)
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(label.last!))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

            // Song info or prompt
            if let song = selectedSong {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(song.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Label("\(song.playCount) plays", systemImage: "play.circle.fill")
                        .font(.caption)
                        .foregroundStyle(color)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select \(label)")
                        .font(.headline)

                    Text("Tap to choose a song")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(color)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Statistics View

private struct StatisticsView: View {
    let stats: LibraryStats

    var body: some View {
        VStack(spacing: 16) {
            StatRow(label: "Total Songs", value: "\(stats.totalSongs)")
            StatRow(label: "With Play Counts", value: "\(stats.songsWithPlayCounts)")
            StatRow(label: "With Local Assets", value: "\(stats.songsWithLocalAssets)")
            StatRow(label: "Average Play Count", value: String(format: "%.1f", stats.averagePlayCount))
        }
        .padding(.vertical, 8)
    }
}

private struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
        }
    }
}

// MARK: - Song Row View

struct SongRowView: View {
    let song: SongInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(song.title)
                .font(.headline)

            Text(song.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label("\(song.playCount) plays", systemImage: "play.circle.fill")
                .font(.caption)
                .foregroundStyle(song.playCount > 0 ? .blue : .secondary)
        }
        .padding(.vertical, 4)
    }
}

