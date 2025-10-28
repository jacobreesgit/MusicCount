import SwiftUI

public struct ContentView: View {
    @State private var service = MusicLibraryService()

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
            .navigationTitle("Library Verification")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Authorization Views

    private var unauthorizedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)

            Text("Music Library Access Required")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This app needs permission to access your music library to verify what content is accessible via MPMediaLibrary.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("Request Access") {
                Task {
                    await service.requestAuthorization()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
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
            case .idle:
                idleView
            case .loading:
                loadingView
            case .loaded(let songs):
                libraryView(songs: songs)
            case .error(let message):
                errorView(message: message)
            }
        }
    }

    // MARK: - Loading States

    private var idleView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Access Granted")
                .font(.title2)
                .fontWeight(.semibold)

            Button("Load Library") {
                Task {
                    await service.loadMusicLibrary()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }

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

            Section("Songs (\(songs.count))") {
                ForEach(songs) { song in
                    SongRowView(song: song)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Refresh") {
                    Task {
                        await service.loadMusicLibrary()
                    }
                }
            }
        }
    }

    public init() {}
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

private struct SongRowView: View {
    let song: SongInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(song.title)
                .font(.headline)

            Text(song.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("\(song.playCount)", systemImage: "play.circle")
                    .font(.caption)
                    .foregroundStyle(song.playCount > 0 ? .blue : .secondary)

                if song.hasAssetURL {
                    Label("Local", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Label("Cloud", systemImage: "icloud")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Label(song.mediaType, systemImage: "waveform")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

