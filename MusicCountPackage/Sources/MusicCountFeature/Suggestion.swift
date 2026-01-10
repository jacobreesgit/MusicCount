import Foundation

/// A group of duplicate songs with the same title/artist but different play counts.
struct Suggestion: Identifiable, Equatable, Sendable {
    let id: UUID
    let sharedTitle: String
    let sharedArtist: String
    private(set) var songs: [SongInfo]

    init(id: UUID = UUID(), sharedTitle: String, sharedArtist: String, songs: [SongInfo]) {
        precondition(songs.count >= 2, "Suggestion must contain at least 2 songs")
        self.id = id
        self.sharedTitle = sharedTitle
        self.sharedArtist = sharedArtist
        self.songs = songs
    }

    var lowestPlayCount: SongInfo {
        // swiftlint:disable:next force_unwrapping
        songs.min(by: { $0.playCount < $1.playCount })!
    }

    var highestPlayCount: SongInfo {
        // swiftlint:disable:next force_unwrapping
        songs.max(by: { $0.playCount < $1.playCount })!
    }

    var playCountDifference: Int {
        highestPlayCount.playCount - lowestPlayCount.playCount
    }

    var versionCount: String {
        "\(songs.count) versions"
    }

    var canDismissIndividualSongs: Bool {
        songs.count > 2
    }

    mutating func updateSongs(_ newSongs: [SongInfo]) {
        precondition(newSongs.count >= 2, "Suggestion must contain at least 2 songs")
        songs = newSongs
    }
}
