import MediaPlayer
import Observation

@MainActor
@Observable
final class MusicLibraryService {
    enum AuthorizationState: Sendable {
        case notDetermined
        case denied
        case restricted
        case authorized
    }

    enum LoadingState: Sendable, Equatable {
        case idle
        case loading
        case loaded([SongInfo])
        case error(String)
    }

    private(set) var authorizationState: AuthorizationState = .notDetermined
    private(set) var loadingState: LoadingState = .idle

    init() {
        checkAuthorizationStatus()
    }

    /// Check current authorization status
    func checkAuthorizationStatus() {
        let status = MPMediaLibrary.authorizationStatus()
        authorizationState = mapAuthorizationStatus(status)
    }

    /// Request authorization to access media library
    func requestAuthorization() async {
        let status = await withCheckedContinuation { continuation in
            MPMediaLibrary.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        authorizationState = mapAuthorizationStatus(status)

        if authorizationState == .authorized {
            await loadMusicLibrary()
        }
    }

    /// Load all songs from the media library
    func loadMusicLibrary() async {
        loadingState = .loading

        // Perform query on background thread
        let songs: [SongInfo] = await Task.detached {
            let query = MPMediaQuery.songs()
            guard let items = query.items else {
                return []
            }

            return items.compactMap { item -> SongInfo? in
                // Extract song information
                guard let persistentID = item.value(forProperty: MPMediaItemPropertyPersistentID) as? UInt64 else {
                    return nil
                }

                let title = item.title ?? "Unknown Title"
                let artist = item.artist ?? "Unknown Artist"
                let album = item.albumTitle ?? "Unknown Album"
                let playCount = item.playCount
                let hasAssetURL = item.assetURL != nil
                let mediaType = Self.mediaTypeDescription(item.mediaType)

                return SongInfo(
                    id: persistentID,
                    title: title,
                    artist: artist,
                    album: album,
                    playCount: playCount,
                    hasAssetURL: hasAssetURL,
                    mediaType: mediaType
                )
            }
        }.value

        if songs.isEmpty {
            loadingState = .error("No songs found in library. This could mean:\n• No locally stored music on device\n• Only Apple Music streaming content (not accessible)\n• Music library is empty")
        } else {
            loadingState = .loaded(songs)
        }
    }

    // MARK: - Private Helpers

    private func mapAuthorizationStatus(_ status: MPMediaLibraryAuthorizationStatus) -> AuthorizationState {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }

    private nonisolated static func mediaTypeDescription(_ mediaType: MPMediaType) -> String {
        switch mediaType {
        case .music:
            return "Music"
        case .podcast:
            return "Podcast"
        case .audioBook:
            return "Audiobook"
        case .anyAudio:
            return "Any Audio"
        default:
            return "Unknown"
        }
    }
}
