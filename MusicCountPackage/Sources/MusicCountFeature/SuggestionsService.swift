import Foundation

@MainActor
@Observable
final class SuggestionsService: Sendable {
    private(set) var allSuggestions: [Suggestion] = []
    private var dismissedKeys: Set<String> = []

    private let dismissedKeysKey = "com.musiccount.dismissedSuggestions"

    init() {
        loadDismissedKeys()
    }

    var activeSuggestions: [Suggestion] {
        allSuggestions
            .compactMap { suggestion in
                let titleKey = normalizeTitle(suggestion.sharedTitle)

                // Check if entire group was dismissed
                if dismissedKeys.contains("\(titleKey)-ENTIRE_GROUP") {
                    return nil
                }

                // Filter out individually dismissed songs
                var filtered = suggestion
                filtered.songs = suggestion.songs.filter { song in
                    !dismissedKeys.contains("\(titleKey)-\(song.id)")
                }

                // Only show if 2+ versions remain
                return filtered.songs.count >= 2 ? filtered : nil
            }
            .sorted { $0.playCountDifference > $1.playCountDifference }
    }

    func analyzeSongs(_ songs: [SongInfo]) {
        // Group songs by normalized title
        var titleGroups: [String: [SongInfo]] = [:]

        for song in songs {
            let normalizedTitle = normalizeTitle(song.title)
            titleGroups[normalizedTitle, default: []].append(song)
        }

        // Create suggestions for groups with 2+ versions
        allSuggestions = titleGroups.compactMap { title, songsInGroup in
            guard songsInGroup.count >= 2 else { return nil }

            // Use the first song's original title as the shared title
            let sharedTitle = songsInGroup[0].title

            // Sort by play count for consistent ordering
            let sortedSongs = songsInGroup.sorted { $0.playCount < $1.playCount }

            return Suggestion(
                sharedTitle: sharedTitle,
                songs: sortedSongs
            )
        }
    }

    /// Dismiss individual song (only allowed when 3+ songs in group)
    func dismissSong(title: String, songId: UInt64) {
        let key = "\(normalizeTitle(title))-\(songId)"
        dismissedKeys.insert(key)
        saveDismissedKeys()
    }

    /// Dismiss entire suggestion group (used for 2-song groups)
    func dismissEntireGroup(title: String) {
        let key = "\(normalizeTitle(title))-ENTIRE_GROUP"
        dismissedKeys.insert(key)
        saveDismissedKeys()
    }

    private func normalizeTitle(_ title: String) -> String {
        title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func loadDismissedKeys() {
        if let data = UserDefaults.standard.array(forKey: dismissedKeysKey) as? [String] {
            dismissedKeys = Set(data)
        }
    }

    private func saveDismissedKeys() {
        UserDefaults.standard.set(Array(dismissedKeys), forKey: dismissedKeysKey)
    }
}
