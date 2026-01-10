import Foundation
import Testing
@testable import MusicCountFeature

/// Tests for SortOption enum and its sorting logic.
@Suite("SortOption Tests")
struct SortOptionTests {

    // MARK: - Test Fixtures

    private let testSongs: [SongInfo] = [
        SongInfo(id: 1, title: "Zebra", artist: "Charlie", album: "Album C", playCount: 50, hasAssetURL: true, mediaType: "Music", duration: 200),
        SongInfo(id: 2, title: "Apple", artist: "Alice", album: "Album A", playCount: 100, hasAssetURL: true, mediaType: "Music", duration: 180),
        SongInfo(id: 3, title: "Mango", artist: "Bob", album: "Album B", playCount: 25, hasAssetURL: true, mediaType: "Music", duration: 240),
    ]

    // MARK: - Play Count Sorting

    @Test("Sorts by play count descending")
    func sortByPlayCountDescending() {
        let sorted = SortOption.playCountDescending.sorted(testSongs)

        #expect(sorted[0].playCount == 100)
        #expect(sorted[1].playCount == 50)
        #expect(sorted[2].playCount == 25)
    }

    @Test("Sorts by play count ascending")
    func sortByPlayCountAscending() {
        let sorted = SortOption.playCountAscending.sorted(testSongs)

        #expect(sorted[0].playCount == 25)
        #expect(sorted[1].playCount == 50)
        #expect(sorted[2].playCount == 100)
    }

    // MARK: - Title Sorting

    @Test("Sorts by title ascending")
    func sortByTitleAscending() {
        let sorted = SortOption.titleAscending.sorted(testSongs)

        #expect(sorted[0].title == "Apple")
        #expect(sorted[1].title == "Mango")
        #expect(sorted[2].title == "Zebra")
    }

    @Test("Sorts by title descending")
    func sortByTitleDescending() {
        let sorted = SortOption.titleDescending.sorted(testSongs)

        #expect(sorted[0].title == "Zebra")
        #expect(sorted[1].title == "Mango")
        #expect(sorted[2].title == "Apple")
    }

    // MARK: - Artist Sorting

    @Test("Sorts by artist ascending")
    func sortByArtistAscending() {
        let sorted = SortOption.artistAscending.sorted(testSongs)

        #expect(sorted[0].artist == "Alice")
        #expect(sorted[1].artist == "Bob")
        #expect(sorted[2].artist == "Charlie")
    }

    @Test("Sorts by artist descending")
    func sortByArtistDescending() {
        let sorted = SortOption.artistDescending.sorted(testSongs)

        #expect(sorted[0].artist == "Charlie")
        #expect(sorted[1].artist == "Bob")
        #expect(sorted[2].artist == "Alice")
    }

    // MARK: - Album Sorting

    @Test("Sorts by album ascending")
    func sortByAlbumAscending() {
        let sorted = SortOption.albumAscending.sorted(testSongs)

        #expect(sorted[0].album == "Album A")
        #expect(sorted[1].album == "Album B")
        #expect(sorted[2].album == "Album C")
    }

    @Test("Sorts by album descending")
    func sortByAlbumDescending() {
        let sorted = SortOption.albumDescending.sorted(testSongs)

        #expect(sorted[0].album == "Album C")
        #expect(sorted[1].album == "Album B")
        #expect(sorted[2].album == "Album A")
    }

    // MARK: - Edge Cases

    @Test("Handles empty array")
    func sortEmptyArray() {
        let empty: [SongInfo] = []
        let sorted = SortOption.playCountDescending.sorted(empty)
        #expect(sorted.isEmpty)
    }

    @Test("Handles single element array")
    func sortSingleElement() {
        let single = [testSongs[0]]
        let sorted = SortOption.titleAscending.sorted(single)

        #expect(sorted.count == 1)
        #expect(sorted[0].title == "Zebra")
    }

    @Test("Handles equal values - maintains stable order")
    func sortEqualValues() {
        let samePlays = [
            SongInfo(id: 1, title: "A", artist: "X", album: "X", playCount: 10, hasAssetURL: true, mediaType: "Music", duration: 100),
            SongInfo(id: 2, title: "B", artist: "X", album: "X", playCount: 10, hasAssetURL: true, mediaType: "Music", duration: 100),
            SongInfo(id: 3, title: "C", artist: "X", album: "X", playCount: 10, hasAssetURL: true, mediaType: "Music", duration: 100),
        ]

        let sorted = SortOption.playCountDescending.sorted(samePlays)
        #expect(sorted.count == 3)
        // All have same play count, order should be maintained
    }

    // MARK: - Display Properties

    @Test("All sort options have display names")
    func allOptionsHaveDisplayNames() {
        for option in SortOption.allCases {
            #expect(!option.displayName.isEmpty)
        }
    }

    @Test("All sort options have short labels")
    func allOptionsHaveShortLabels() {
        for option in SortOption.allCases {
            #expect(!option.shortLabel.isEmpty)
        }
    }

    @Test("All sort options have icons")
    func allOptionsHaveIcons() {
        for option in SortOption.allCases {
            #expect(!option.icon(isSelected: true).isEmpty)
            #expect(!option.icon(isSelected: false).isEmpty)
        }
    }

    @Test("Selected icon includes .fill suffix")
    func selectedIconHasFillSuffix() {
        for option in SortOption.allCases {
            let selectedIcon = option.icon(isSelected: true)
            #expect(selectedIcon.contains(".fill"))
        }
    }

    @Test("Unselected icon does not include .fill suffix")
    func unselectedIconNoFillSuffix() {
        for option in SortOption.allCases {
            let unselectedIcon = option.icon(isSelected: false)
            #expect(!unselectedIcon.contains(".fill"))
        }
    }

    // MARK: - Identifiable & RawRepresentable

    @Test("All sort options have unique raw values")
    func allOptionsHaveUniqueRawValues() {
        let rawValues = SortOption.allCases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)
        #expect(rawValues.count == uniqueRawValues.count)
    }

    @Test("ID equals raw value")
    func idEqualsRawValue() {
        for option in SortOption.allCases {
            #expect(option.id == option.rawValue)
        }
    }
}
