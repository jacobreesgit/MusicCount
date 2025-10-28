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
                let groupKey = "\(normalizeTitle(suggestion.sharedTitle))-\(normalizeArtist(suggestion.sharedArtist))"

                // Check if entire group was dismissed
                if dismissedKeys.contains("\(groupKey)-ENTIRE_GROUP") {
                    return nil
                }

                // Filter out individually dismissed songs
                var filtered = suggestion
                filtered.songs = suggestion.songs.filter { song in
                    !dismissedKeys.contains("\(groupKey)-\(song.id)")
                }

                // Only show if 2+ versions remain
                return filtered.songs.count >= 2 ? filtered : nil
            }
            .sorted { $0.playCountDifference > $1.playCountDifference }
    }

    func analyzeSongs(_ songs: [SongInfo]) {
        // Group songs by normalized title AND artist
        var titleArtistGroups: [String: [SongInfo]] = [:]

        for song in songs {
            let groupKey = "\(normalizeTitle(song.title))-\(normalizeArtist(song.artist))"
            titleArtistGroups[groupKey, default: []].append(song)
        }

        // Create suggestions for groups with 2+ versions
        allSuggestions = titleArtistGroups.compactMap { _, songsInGroup in
            guard songsInGroup.count >= 2 else { return nil }

            // Use the first song's original title and artist as the shared values
            let sharedTitle = songsInGroup[0].title
            let sharedArtist = songsInGroup[0].artist

            // Sort by play count for consistent ordering
            let sortedSongs = songsInGroup.sorted { $0.playCount < $1.playCount }

            return Suggestion(
                sharedTitle: sharedTitle,
                sharedArtist: sharedArtist,
                songs: sortedSongs
            )
        }
    }

    /// Dismiss individual song (only allowed when 3+ songs in group)
    func dismissSong(title: String, artist: String, songId: UInt64) {
        let key = "\(normalizeTitle(title))-\(normalizeArtist(artist))-\(songId)"
        dismissedKeys.insert(key)
        saveDismissedKeys()
    }

    /// Dismiss entire suggestion group (used for 2-song groups)
    func dismissEntireGroup(title: String, artist: String) {
        let key = "\(normalizeTitle(title))-\(normalizeArtist(artist))-ENTIRE_GROUP"
        dismissedKeys.insert(key)
        saveDismissedKeys()
    }

    /// Reset all dismissed suggestions (both individual songs and entire groups)
    func resetDismissals() {
        dismissedKeys.removeAll()
        UserDefaults.standard.removeObject(forKey: dismissedKeysKey)
    }

    private func normalizeTitle(_ title: String) -> String {
        title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizeArtist(_ artist: String) -> String {
        artist.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
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
