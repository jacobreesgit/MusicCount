import Foundation

struct Suggestion: Identifiable, Equatable, Sendable {
    let id: UUID
    let sharedTitle: String
    let sharedArtist: String
    var songs: [SongInfo]

    init(id: UUID = UUID(), sharedTitle: String, sharedArtist: String, songs: [SongInfo]) {
        self.id = id
        self.sharedTitle = sharedTitle
        self.sharedArtist = sharedArtist
        self.songs = songs
    }

    var lowestPlayCount: SongInfo {
        songs.min(by: { $0.playCount < $1.playCount })!
    }

    var highestPlayCount: SongInfo {
        songs.max(by: { $0.playCount < $1.playCount })!
    }

    var playCountDifference: Int {
        highestPlayCount.playCount - lowestPlayCount.playCount
    }

    var versionCount: String {
        "\(songs.count) versions"
    }

    /// UI logic: Can only dismiss individual songs when 3 or more versions exist
    var canDismissIndividualSongs: Bool {
        songs.count > 2
    }
}
