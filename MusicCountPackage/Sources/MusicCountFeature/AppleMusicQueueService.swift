import MediaPlayer
import Observation
import SwiftUI

/// Manages adding songs to the Apple Music playback queue.
@MainActor
@Observable
final class AppleMusicQueueService {
    enum QueueError: Error, LocalizedError {
        case songNotFound
        case noStoreID
        case queueFailed

        var errorDescription: String? {
            switch self {
            case .songNotFound:
                return "The song could not be found in your library."
            case .noStoreID:
                return "This song cannot be queued because it's not available in Apple Music."
            case .queueFailed:
                return "Failed to add the song to the queue. Please try again."
            }
        }
    }

    private let systemPlayer = MPMusicPlayerController.systemMusicPlayer

    /// Adds a song to the queue `count` times, using the user's preferred queue behavior.
    func addToQueue(song: SongInfo, count: Int) throws {
        // Find the song in MPMediaLibrary
        let query = MPMediaQuery.songs()
        guard let items = query.items,
              let mediaItem = items.first(where: { $0.persistentID == song.id }) else {
            throw QueueError.songNotFound
        }

        // Get the store ID (catalog ID) for the song
        let storeID = mediaItem.playbackStoreID
        guard !storeID.isEmpty else {
            throw QueueError.noStoreID
        }

        // Create N copies of the store ID
        let storeIDs = Array(repeating: storeID, count: count)

        // Create queue descriptor with store IDs
        let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)

        // Get user's queue behavior preference
        let behaviorRawValue = UserDefaults.standard.string(forKey: StorageKeys.queueBehavior) ?? QueueBehavior.insertNext.rawValue
        let behavior = QueueBehavior(rawValue: behaviorRawValue) ?? .insertNext

        // Apply the appropriate queue method based on user preference
        switch behavior {
        case .replaceQueue:
            // Replace entire queue and start playing
            systemPlayer.setQueue(with: descriptor)
            systemPlayer.prepareToPlay { [weak self] error in
                guard error == nil else { return }
                Task { @MainActor in
                    self?.systemPlayer.play()
                }
            }

        case .insertNext:
            // Insert after current song (plays next)
            systemPlayer.prepend(descriptor)
            systemPlayer.play()
        }
    }
}
