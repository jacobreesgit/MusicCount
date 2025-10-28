import Foundation
import UIKit

/// Represents song information extracted from MPMediaLibrary
struct SongInfo: Identifiable, Sendable, Equatable {
    let id: UInt64
    let title: String
    let artist: String
    let album: String
    let playCount: Int
    let hasAssetURL: Bool
    let mediaType: String
    let duration: TimeInterval
    let artworkImage: UIImage?

    init(
        id: UInt64,
        title: String,
        artist: String,
        album: String,
        playCount: Int,
        hasAssetURL: Bool,
        mediaType: String,
        duration: TimeInterval,
        artworkImage: UIImage? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.playCount = playCount
        self.hasAssetURL = hasAssetURL
        self.mediaType = mediaType
        self.duration = duration
        self.artworkImage = artworkImage
    }

    /// Formatted duration string (M:SS or H:MM:SS)
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    /// Formatted duration for accessibility (e.g., "3 minutes 45 seconds")
    var accessibleDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var components: [String] = []

        if hours > 0 {
            components.append("\(hours) \(hours == 1 ? "hour" : "hours")")
        }
        if minutes > 0 {
            components.append("\(minutes) \(minutes == 1 ? "minute" : "minutes")")
        }
        if seconds > 0 || components.isEmpty {
            components.append("\(seconds) \(seconds == 1 ? "second" : "seconds")")
        }

        return components.joined(separator: " ")
    }

    /// Whether artwork is available
    var hasArtwork: Bool {
        artworkImage != nil
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
