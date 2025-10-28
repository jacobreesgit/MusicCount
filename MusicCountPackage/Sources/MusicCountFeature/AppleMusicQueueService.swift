import MediaPlayer
import Observation
import SwiftUI

@MainActor
@Observable
final class AppleMusicQueueService {
    enum QueueError: Error {
        case songNotFound
        case noStoreID
        case queueFailed
    }

    private let systemPlayer = MPMusicPlayerController.systemMusicPlayer

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
        let behaviorRawValue = UserDefaults.standard.string(forKey: "queueBehavior") ?? QueueBehavior.insertNext.rawValue
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

        case .appendToEnd:
            // Add to end of existing queue
            systemPlayer.append(descriptor)
            systemPlayer.play()

        case .insertNext:
            // Insert after current song (plays next)
            systemPlayer.prepend(descriptor)
            systemPlayer.play()
        }
    }
}
