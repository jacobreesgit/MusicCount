import Foundation
import Testing
@testable import MusicCountFeature

/// Tests for LibraryStats model.
@Suite("LibraryStats Tests")
struct LibraryStatsTests {

    // MARK: - Test Fixtures

    private func makeSong(
        id: UInt64,
        playCount: Int,
        hasAssetURL: Bool = true
    ) -> SongInfo {
        SongInfo(
            id: id,
            title: "Test Song \(id)",
            artist: "Test Artist",
            album: "Test Album",
            playCount: playCount,
            hasAssetURL: hasAssetURL,
            mediaType: "Music",
            duration: 200
        )
    }

    // MARK: - Total Songs Tests

    @Test("Total songs count is correct")
    func totalSongs() {
        let songs = [
            makeSong(id: 1, playCount: 10),
            makeSong(id: 2, playCount: 20),
            makeSong(id: 3, playCount: 30),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.totalSongs == 3)
    }

    @Test("Total songs is zero for empty library")
    func totalSongsEmpty() {
        let stats = LibraryStats(songs: [])
        #expect(stats.totalSongs == 0)
    }

    // MARK: - Songs With Play Counts Tests

    @Test("Counts songs with play counts correctly")
    func songsWithPlayCounts() {
        let songs = [
            makeSong(id: 1, playCount: 0),  // Not played
            makeSong(id: 2, playCount: 10), // Played
            makeSong(id: 3, playCount: 0),  // Not played
            makeSong(id: 4, playCount: 5),  // Played
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.songsWithPlayCounts == 2)
    }

    @Test("All songs with play counts")
    func allSongsWithPlayCounts() {
        let songs = [
            makeSong(id: 1, playCount: 10),
            makeSong(id: 2, playCount: 20),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.songsWithPlayCounts == 2)
    }

    @Test("No songs with play counts")
    func noSongsWithPlayCounts() {
        let songs = [
            makeSong(id: 1, playCount: 0),
            makeSong(id: 2, playCount: 0),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.songsWithPlayCounts == 0)
    }

    // MARK: - Songs With Local Assets Tests

    @Test("Counts songs with local assets correctly")
    func songsWithLocalAssets() {
        let songs = [
            makeSong(id: 1, playCount: 10, hasAssetURL: true),
            makeSong(id: 2, playCount: 20, hasAssetURL: false),
            makeSong(id: 3, playCount: 30, hasAssetURL: true),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.songsWithLocalAssets == 2)
    }

    @Test("All songs with local assets")
    func allSongsWithLocalAssets() {
        let songs = [
            makeSong(id: 1, playCount: 10, hasAssetURL: true),
            makeSong(id: 2, playCount: 20, hasAssetURL: true),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.songsWithLocalAssets == 2)
    }

    @Test("No songs with local assets")
    func noSongsWithLocalAssets() {
        let songs = [
            makeSong(id: 1, playCount: 10, hasAssetURL: false),
            makeSong(id: 2, playCount: 20, hasAssetURL: false),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.songsWithLocalAssets == 0)
    }

    // MARK: - Average Play Count Tests

    @Test("Calculates average play count correctly")
    func averagePlayCount() {
        let songs = [
            makeSong(id: 1, playCount: 10),
            makeSong(id: 2, playCount: 20),
            makeSong(id: 3, playCount: 30),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.averagePlayCount == 20.0) // (10 + 20 + 30) / 3
    }

    @Test("Average play count is zero for empty library")
    func averagePlayCountEmpty() {
        let stats = LibraryStats(songs: [])
        #expect(stats.averagePlayCount == 0.0)
    }

    @Test("Average play count handles single song")
    func averagePlayCountSingle() {
        let songs = [makeSong(id: 1, playCount: 42)]
        let stats = LibraryStats(songs: songs)
        #expect(stats.averagePlayCount == 42.0)
    }

    @Test("Average play count with zero plays")
    func averagePlayCountWithZeros() {
        let songs = [
            makeSong(id: 1, playCount: 0),
            makeSong(id: 2, playCount: 0),
            makeSong(id: 3, playCount: 30),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.averagePlayCount == 10.0) // (0 + 0 + 30) / 3
    }

    @Test("Average play count decimal precision")
    func averagePlayCountDecimal() {
        let songs = [
            makeSong(id: 1, playCount: 1),
            makeSong(id: 2, playCount: 2),
        ]
        let stats = LibraryStats(songs: songs)
        #expect(stats.averagePlayCount == 1.5)
    }
}
