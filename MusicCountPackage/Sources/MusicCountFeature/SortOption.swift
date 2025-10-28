import Foundation

/// Options for sorting the song list
enum SortOption: String, CaseIterable, Identifiable, Sendable {
    case playCountDescending = "playCountDescending"
    case playCountAscending = "playCountAscending"
    case titleAscending = "titleAscending"
    case titleDescending = "titleDescending"
    case artistAscending = "artistAscending"
    case artistDescending = "artistDescending"

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
        }
    }

    /// Sort an array of songs based on this option
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
        }
    }

    /// Icon that represents the sort direction
    /// - Parameter isSelected: Whether this option is currently selected
    /// - Returns: SF Symbol name for the icon (filled if selected, outline if not)
    func icon(isSelected: Bool) -> String {
        let suffix = isSelected ? ".fill" : ""
        switch self {
        case .playCountDescending, .titleDescending, .artistDescending:
            return "arrow.down.circle\(suffix)"
        case .playCountAscending, .titleAscending, .artistAscending:
            return "arrow.up.circle\(suffix)"
        }
    }
}
