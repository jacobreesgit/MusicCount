import MediaPlayer
import Observation

/// Handles authorization and loading of the user's Apple Music library.
@MainActor
@Observable
class MusicLibraryService {
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

    var authorizationState: AuthorizationState = .notDetermined
    var loadingState: LoadingState = .idle

    init() {
        checkAuthorizationStatus()
    }

    /// Refreshes authorization state without prompting the user.
    func checkAuthorizationStatus() {
        let status = MPMediaLibrary.authorizationStatus()
        authorizationState = mapAuthorizationStatus(status)
    }

    /// Requests media library access. Loads library automatically if granted.
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

    /// Loads all songs from the media library on a background thread.
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
                let duration = item.playbackDuration

                // Extract artwork image at 50x50pt size
                let artworkImage = item.artwork?.image(at: CGSize(width: 50, height: 50))

                return SongInfo(
                    id: persistentID,
                    title: title,
                    artist: artist,
                    album: album,
                    playCount: playCount,
                    hasAssetURL: hasAssetURL,
                    mediaType: mediaType,
                    duration: duration,
                    artworkImage: artworkImage
                )
            }
        }.value

        loadingState = .loaded(songs)
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
