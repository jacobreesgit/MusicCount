import Foundation

/// Represents song information extracted from MPMediaLibrary
struct SongInfo: Identifiable, Sendable {
    let id: UInt64
    let title: String
    let artist: String
    let album: String
    let playCount: Int
    let hasAssetURL: Bool
    let mediaType: String

    init(
        id: UInt64,
        title: String,
        artist: String,
        album: String,
        playCount: Int,
        hasAssetURL: Bool,
        mediaType: String
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.playCount = playCount
        self.hasAssetURL = hasAssetURL
        self.mediaType = mediaType
    }
}

/// Summary statistics about the music library
struct LibraryStats: Sendable {
    let totalSongs: Int
    let songsWithPlayCounts: Int
    let songsWithLocalAssets: Int
    let averagePlayCount: Double

    init(songs: [SongInfo]) {
        self.totalSongs = songs.count
        self.songsWithPlayCounts = songs.filter { $0.playCount > 0 }.count
        self.songsWithLocalAssets = songs.filter { $0.hasAssetURL }.count

        let totalPlays = songs.reduce(0) { $0 + $1.playCount }
        self.averagePlayCount = songs.isEmpty ? 0 : Double(totalPlays) / Double(songs.count)
    }
}
