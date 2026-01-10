import Foundation
import Testing
@testable import MusicCountFeature

/// Tests for SongInfo model and its computed properties.
@Suite("SongInfo Tests")
struct SongInfoTests {

    // MARK: - Test Fixtures

    /// Creates a SongInfo with the given duration for testing.
    private func makeSong(duration: TimeInterval) -> SongInfo {
        SongInfo(
            id: 1,
            title: "Test Song",
            artist: "Test Artist",
            album: "Test Album",
            playCount: 10,
            hasAssetURL: true,
            mediaType: "Music",
            duration: duration
        )
    }

    // MARK: - Formatted Duration Tests

    @Test("Formats duration under a minute correctly")
    func formattedDurationUnderMinute() {
        let song = makeSong(duration: 45)
        #expect(song.formattedDuration == "0:45")
    }

    @Test("Formats duration of exactly one minute")
    func formattedDurationOneMinute() {
        let song = makeSong(duration: 60)
        #expect(song.formattedDuration == "1:00")
    }

    @Test("Formats typical song duration (3:45)")
    func formattedDurationTypical() {
        let song = makeSong(duration: 225) // 3 minutes 45 seconds
        #expect(song.formattedDuration == "3:45")
    }

    @Test("Formats duration with single digit seconds with leading zero")
    func formattedDurationLeadingZero() {
        let song = makeSong(duration: 123) // 2 minutes 3 seconds
        #expect(song.formattedDuration == "2:03")
    }

    @Test("Formats duration over an hour")
    func formattedDurationOverHour() {
        let song = makeSong(duration: 3725) // 1 hour 2 minutes 5 seconds
        #expect(song.formattedDuration == "1:02:05")
    }

    @Test("Formats zero duration")
    func formattedDurationZero() {
        let song = makeSong(duration: 0)
        #expect(song.formattedDuration == "0:00")
    }

    // MARK: - Accessible Duration Tests

    @Test("Accessible duration for seconds only")
    func accessibleDurationSecondsOnly() {
        let song = makeSong(duration: 45)
        #expect(song.accessibleDuration == "45 seconds")
    }

    @Test("Accessible duration for one second")
    func accessibleDurationOneSecond() {
        let song = makeSong(duration: 1)
        #expect(song.accessibleDuration == "1 second")
    }

    @Test("Accessible duration for one minute")
    func accessibleDurationOneMinute() {
        let song = makeSong(duration: 60)
        #expect(song.accessibleDuration == "1 minute")
    }

    @Test("Accessible duration for minutes and seconds")
    func accessibleDurationMinutesAndSeconds() {
        let song = makeSong(duration: 225) // 3 minutes 45 seconds
        #expect(song.accessibleDuration == "3 minutes 45 seconds")
    }

    @Test("Accessible duration for hours, minutes, and seconds")
    func accessibleDurationFull() {
        let song = makeSong(duration: 3725) // 1 hour 2 minutes 5 seconds
        #expect(song.accessibleDuration == "1 hour 2 minutes 5 seconds")
    }

    @Test("Accessible duration uses singular forms correctly")
    func accessibleDurationSingular() {
        let song = makeSong(duration: 3661) // 1 hour 1 minute 1 second
        #expect(song.accessibleDuration == "1 hour 1 minute 1 second")
    }

    @Test("Accessible duration for zero shows 0 seconds")
    func accessibleDurationZero() {
        let song = makeSong(duration: 0)
        #expect(song.accessibleDuration == "0 seconds")
    }

    // MARK: - Has Artwork Tests

    @Test("hasArtwork returns false when no artwork")
    func hasArtworkFalse() {
        let song = makeSong(duration: 100)
        #expect(song.hasArtwork == false)
    }

    // MARK: - Equatable Tests

    @Test("Songs with identical properties are equal")
    func songsEqualByAllProperties() {
        let song1 = SongInfo(
            id: 123,
            title: "Song A",
            artist: "Artist A",
            album: "Album A",
            playCount: 10,
            hasAssetURL: true,
            mediaType: "Music",
            duration: 200
        )
        let song2 = SongInfo(
            id: 123,
            title: "Song A",
            artist: "Artist A",
            album: "Album A",
            playCount: 10,
            hasAssetURL: true,
            mediaType: "Music",
            duration: 200
        )
        #expect(song1 == song2)
    }

    @Test("Songs with different IDs are not equal")
    func songsDifferentIds() {
        let song1 = makeSong(duration: 100)
        let song2 = SongInfo(
            id: 2,
            title: "Test Song",
            artist: "Test Artist",
            album: "Test Album",
            playCount: 10,
            hasAssetURL: true,
            mediaType: "Music",
            duration: 100
        )
        #expect(song1 != song2)
    }

    @Test("Songs with same ID but different properties are not equal")
    func songsSameIdDifferentProperties() {
        let song1 = SongInfo(
            id: 123,
            title: "Song A",
            artist: "Artist A",
            album: "Album A",
            playCount: 10,
            hasAssetURL: true,
            mediaType: "Music",
            duration: 200
        )
        let song2 = SongInfo(
            id: 123,
            title: "Different Title",
            artist: "Different Artist",
            album: "Different Album",
            playCount: 50,
            hasAssetURL: false,
            mediaType: "Podcast",
            duration: 300
        )
        #expect(song1 != song2)
    }
}
