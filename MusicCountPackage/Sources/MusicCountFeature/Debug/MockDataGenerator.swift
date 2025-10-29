#if DEBUG
import Foundation
import UIKit

/// Generates SongInfo objects from mock data with real album artwork
@MainActor
final class MockDataGenerator {
    private let artworkFetcher = AlbumArtworkFetcher()

    /// Generate complete mock library with real album artwork
    /// - Returns: Array of SongInfo objects ready for display
    func generateMockLibrary() async -> [SongInfo] {
        NSLog("📀 Generating mock library with real album artwork...")

        // Fetch all album artwork in parallel
        let uniqueAlbums = MockSongData.uniqueAlbums
        NSLog("🎨 Fetching artwork for \(uniqueAlbums.count) unique albums...")

        let artworkMap = await artworkFetcher.fetchAllArtwork(for: uniqueAlbums)
        NSLog("✅ Fetched \(artworkMap.count) album artworks")

        // Convert mock songs to SongInfo with artwork
        let songs = MockSongData.songs.enumerated().map { (index, mockSong) -> SongInfo in
            let artworkKey = "\(mockSong.artist)|\(mockSong.album)"
            let artwork = artworkMap[artworkKey]

            return SongInfo(
                id: UInt64(index),
                title: mockSong.title,
                artist: mockSong.artist,
                album: mockSong.album,
                playCount: mockSong.playCount,
                hasAssetURL: true,
                mediaType: "Music",
                duration: mockSong.duration,
                artworkImage: artwork
            )
        }

        NSLog("✅ Generated \(songs.count) mock songs")
        return songs
    }
}
#endif
