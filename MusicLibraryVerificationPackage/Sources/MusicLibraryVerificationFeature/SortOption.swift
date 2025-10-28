import Foundation

/// Options for sorting the song list
enum SortOption: String, CaseIterable, Identifiable, Sendable {
    case playCountDescending = "Play Count (High to Low)"
    case playCountAscending = "Play Count (Low to High)"
    case titleAscending = "Title (A-Z)"
    case titleDescending = "Title (Z-A)"
    case artistAscending = "Artist (A-Z)"
    case artistDescending = "Artist (Z-A)"

    var id: String { rawValue }

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
        case .playCountDescending: return "Play Count ↓"
        case .playCountAscending: return "Play Count ↑"
        case .titleAscending: return "Title ↑"
        case .titleDescending: return "Title ↓"
        case .artistAscending: return "Artist ↑"
        case .artistDescending: return "Artist ↓"
        }
    }
}
