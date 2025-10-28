import Foundation

/// Represents an active play count matching session
struct MatchingSession: Codable, Sendable {
    enum Mode: String, Codable, Sendable {
        case match // Match lower to higher count
        case add   // Add difference to lower count
    }

    let songId: UInt64
    let songTitle: String
    let songArtist: String
    let targetPlays: Int
    var startingSystemPlayCount: Int
    let mode: Mode
    var completedPlays: Int
    let createdAt: Date
    var lastPlayedAt: Date?

    init(
        songId: UInt64,
        songTitle: String,
        songArtist: String,
        targetPlays: Int,
        startingSystemPlayCount: Int,
        mode: Mode
    ) {
        self.songId = songId
        self.songTitle = songTitle
        self.songArtist = songArtist
        self.targetPlays = targetPlays
        self.startingSystemPlayCount = startingSystemPlayCount
        self.mode = mode
        self.completedPlays = 0
        self.createdAt = Date()
        self.lastPlayedAt = nil
    }

    var playsNeeded: Int {
        max(0, targetPlays - completedPlays)
    }

    var isCompleted: Bool {
        completedPlays >= targetPlays
    }

    var progress: Double {
        guard targetPlays > 0 else { return 0 }
        return Double(completedPlays) / Double(targetPlays)
    }
}
