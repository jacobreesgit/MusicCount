import Foundation
import Testing
@testable import MusicCountFeature

/// Tests for Suggestion model and its computed properties.
@Suite("Suggestion Tests")
struct SuggestionTests {

    // MARK: - Test Fixtures

    private func makeSong(id: UInt64, playCount: Int) -> SongInfo {
        SongInfo(
            id: id,
            title: "Test Song",
            artist: "Test Artist",
            album: "Test Album",
            playCount: playCount,
            hasAssetURL: true,
            mediaType: "Music",
            duration: 200
        )
    }

    private func makeSuggestion(playCounts: [Int]) -> Suggestion {
        let songs = playCounts.enumerated().map { index, playCount in
            makeSong(id: UInt64(index + 1), playCount: playCount)
        }
        return Suggestion(
            sharedTitle: "Test Song",
            sharedArtist: "Test Artist",
            songs: songs
        )
    }

    // MARK: - Initialization Tests

    @Test("Creates suggestion with minimum 2 songs")
    func createWithTwoSongs() {
        let suggestion = makeSuggestion(playCounts: [10, 20])
        #expect(suggestion.songs.count == 2)
    }

    @Test("Creates suggestion with multiple songs")
    func createWithMultipleSongs() {
        let suggestion = makeSuggestion(playCounts: [10, 20, 30, 40])
        #expect(suggestion.songs.count == 4)
    }

    // MARK: - Lowest Play Count Tests

    @Test("Returns song with lowest play count")
    func lowestPlayCount() {
        let suggestion = makeSuggestion(playCounts: [50, 10, 30])
        #expect(suggestion.lowestPlayCount.playCount == 10)
    }

    @Test("Returns first lowest when multiple have same low count")
    func lowestPlayCountTie() {
        let suggestion = makeSuggestion(playCounts: [10, 10, 30])
        #expect(suggestion.lowestPlayCount.playCount == 10)
    }

    // MARK: - Highest Play Count Tests

    @Test("Returns song with highest play count")
    func highestPlayCount() {
        let suggestion = makeSuggestion(playCounts: [50, 10, 30])
        #expect(suggestion.highestPlayCount.playCount == 50)
    }

    @Test("Returns first highest when multiple have same high count")
    func highestPlayCountTie() {
        let suggestion = makeSuggestion(playCounts: [50, 50, 30])
        #expect(suggestion.highestPlayCount.playCount == 50)
    }

    // MARK: - Play Count Difference Tests

    @Test("Calculates correct play count difference")
    func playCountDifferenceBasic() {
        let suggestion = makeSuggestion(playCounts: [10, 50])
        #expect(suggestion.playCountDifference == 40)
    }

    @Test("Returns zero difference when all same")
    func playCountDifferenceZero() {
        let suggestion = makeSuggestion(playCounts: [25, 25])
        #expect(suggestion.playCountDifference == 0)
    }

    @Test("Calculates difference with multiple songs")
    func playCountDifferenceMultiple() {
        let suggestion = makeSuggestion(playCounts: [5, 15, 25, 35])
        #expect(suggestion.playCountDifference == 30) // 35 - 5
    }

    // MARK: - Version Count Tests

    @Test("Returns correct version count string for 2 songs")
    func versionCountTwo() {
        let suggestion = makeSuggestion(playCounts: [10, 20])
        #expect(suggestion.versionCount == "2 versions")
    }

    @Test("Returns correct version count string for 5 songs")
    func versionCountFive() {
        let suggestion = makeSuggestion(playCounts: [10, 20, 30, 40, 50])
        #expect(suggestion.versionCount == "5 versions")
    }

    // MARK: - Can Dismiss Individual Songs Tests

    @Test("Cannot dismiss individual songs with 2 versions")
    func cannotDismissIndividualWithTwo() {
        let suggestion = makeSuggestion(playCounts: [10, 20])
        #expect(suggestion.canDismissIndividualSongs == false)
    }

    @Test("Can dismiss individual songs with 3+ versions")
    func canDismissIndividualWithThree() {
        let suggestion = makeSuggestion(playCounts: [10, 20, 30])
        #expect(suggestion.canDismissIndividualSongs == true)
    }

    @Test("Can dismiss individual songs with many versions")
    func canDismissIndividualWithMany() {
        let suggestion = makeSuggestion(playCounts: [10, 20, 30, 40, 50])
        #expect(suggestion.canDismissIndividualSongs == true)
    }

    // MARK: - Update Songs Tests

    @Test("Updates songs array correctly")
    func updateSongs() {
        var suggestion = makeSuggestion(playCounts: [10, 20, 30])
        let newSongs = [
            makeSong(id: 1, playCount: 10),
            makeSong(id: 2, playCount: 20),
        ]
        suggestion.updateSongs(newSongs)
        #expect(suggestion.songs.count == 2)
    }

    // MARK: - Equatable Tests

    @Test("Suggestions with identical properties are equal")
    func suggestionsEqualByAllProperties() {
        let id = UUID()
        let songs = [makeSong(id: 1, playCount: 10), makeSong(id: 2, playCount: 20)]
        let suggestion1 = Suggestion(
            id: id,
            sharedTitle: "Title A",
            sharedArtist: "Artist A",
            songs: songs
        )
        let suggestion2 = Suggestion(
            id: id,
            sharedTitle: "Title A",
            sharedArtist: "Artist A",
            songs: songs
        )
        #expect(suggestion1 == suggestion2)
    }

    @Test("Suggestions with different IDs are not equal")
    func suggestionsDifferentIds() {
        let suggestion1 = makeSuggestion(playCounts: [10, 20])
        let suggestion2 = makeSuggestion(playCounts: [10, 20])
        #expect(suggestion1 != suggestion2) // Different UUIDs
    }
}
