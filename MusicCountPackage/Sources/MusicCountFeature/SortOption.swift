import Foundation

/// Sort field and direction options for the song list.
enum SortOption: String, CaseIterable, Identifiable, Sendable {
    case playCountDescending = "playCountDescending"
    case playCountAscending = "playCountAscending"
    case titleAscending = "titleAscending"
    case titleDescending = "titleDescending"
    case artistAscending = "artistAscending"
    case artistDescending = "artistDescending"
    case albumAscending = "albumAscending"
    case albumDescending = "albumDescending"

    var id: String { rawValue }

    /// Display name for the sort option
    var displayName: String {
        switch self {
        case .playCountDescending, .playCountAscending:
            return "Play Count"
        case .titleAscending, .titleDescending:
            return "Title"
        case .artistAscending, .artistDescending:
            return "Artist"
        case .albumAscending, .albumDescending:
            return "Album"
        }
    }

    /// Returns songs sorted by this option's field and direction.
    func sorted(_ songs: [SongInfo]) -> [SongInfo] {
        switch self {
        case .playCountDescending:
            return songs.sorted { $0.playCount > $1.playCount }
        case .playCountAscending:
            return songs.sorted { $0.playCount < $1.playCount }
        case .titleAscending:
            return songs.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        case .titleDescending:
            return songs.sorted { $0.title.localizedStandardCompare($1.title) == .orderedDescending }
        case .artistAscending:
            return songs.sorted { $0.artist.localizedStandardCompare($1.artist) == .orderedAscending }
        case .artistDescending:
            return songs.sorted { $0.artist.localizedStandardCompare($1.artist) == .orderedDescending }
        case .albumAscending:
            return songs.sorted { $0.album.localizedStandardCompare($1.album) == .orderedAscending }
        case .albumDescending:
            return songs.sorted { $0.album.localizedStandardCompare($1.album) == .orderedDescending }
        }
    }

    /// Short label for display in toolbar
    var shortLabel: String {
        switch self {
        case .playCountDescending: return "Play Count"
        case .playCountAscending: return "Play Count"
        case .titleAscending: return "Title"
        case .titleDescending: return "Title"
        case .artistAscending: return "Artist"
        case .artistDescending: return "Artist"
        case .albumAscending: return "Album"
        case .albumDescending: return "Album"
        }
    }

    /// SF Symbol for direction (filled when selected).
    func icon(isSelected: Bool) -> String {
        let suffix = isSelected ? ".fill" : ""
        switch self {
        case .playCountDescending, .titleDescending, .artistDescending, .albumDescending:
            return "arrow.down.circle\(suffix)"
        case .playCountAscending, .titleAscending, .artistAscending, .albumAscending:
            return "arrow.up.circle\(suffix)"
        }
    }
}
