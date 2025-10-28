import MediaPlayer
import Observation

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

        // Append to the system music player's queue
        systemPlayer.append(descriptor)

        // Activate the queue by playing
        systemPlayer.play()
    }
}
