#if DEBUG
import Foundation

/// Mock song definition for generating realistic test data
struct MockSong: Sendable {
    let title: String
    let artist: String
    let album: String
    let playCount: Int
    let duration: TimeInterval

    init(title: String, artist: String, album: String, playCount: Int, duration: TimeInterval = 210) {
        self.title = title
        self.artist = artist
        self.album = album
        self.playCount = playCount
        self.duration = duration
    }
}

/// Curated list of mock songs for App Store screenshots
/// Includes variety of play counts, artists, albums, and duplicate songs for Suggestions feature
enum MockSongData {
    static let songs: [MockSong] = [
        // Taylor Swift - 1989 (Deluxe) - High play counts
        MockSong(title: "Shake It Off", artist: "Taylor Swift", album: "1989 (Deluxe)", playCount: 287, duration: 219),
        MockSong(title: "Blank Space", artist: "Taylor Swift", album: "1989 (Deluxe)", playCount: 245, duration: 231),
        MockSong(title: "Style", artist: "Taylor Swift", album: "1989 (Deluxe)", playCount: 198, duration: 231),

        // Taylor Swift - Singles Collection (DUPLICATE - lower counts for Suggestions)
        MockSong(title: "Shake It Off", artist: "Taylor Swift", album: "Pop Hits 2014", playCount: 67, duration: 219),
        MockSong(title: "Blank Space", artist: "Taylor Swift", album: "Greatest Hits", playCount: 45, duration: 231),

        // The Beatles - Abbey Road
        MockSong(title: "Come Together", artist: "The Beatles", album: "Abbey Road", playCount: 342, duration: 259),
        MockSong(title: "Here Comes the Sun", artist: "The Beatles", album: "Abbey Road", playCount: 456, duration: 185),
        MockSong(title: "Something", artist: "The Beatles", album: "Abbey Road", playCount: 298, duration: 182),

        // The Beatles - Greatest Hits (DUPLICATE)
        MockSong(title: "Come Together", artist: "The Beatles", album: "1", playCount: 89, duration: 259),
        MockSong(title: "Here Comes the Sun", artist: "The Beatles", album: "The Beatles 1967-1970", playCount: 134, duration: 185),

        // Billie Eilish - WHEN WE ALL FALL ASLEEP
        MockSong(title: "bad guy", artist: "Billie Eilish", album: "WHEN WE ALL FALL ASLEEP, WHERE DO WE GO?", playCount: 521, duration: 194),
        MockSong(title: "bury a friend", artist: "Billie Eilish", album: "WHEN WE ALL FALL ASLEEP, WHERE DO WE GO?", playCount: 378, duration: 193),
        MockSong(title: "when the party's over", artist: "Billie Eilish", album: "WHEN WE ALL FALL ASLEEP, WHERE DO WE GO?", playCount: 402, duration: 196),

        // Fleetwood Mac - Rumours
        MockSong(title: "Dreams", artist: "Fleetwood Mac", album: "Rumours", playCount: 267, duration: 257),
        MockSong(title: "Go Your Own Way", artist: "Fleetwood Mac", album: "Rumours", playCount: 312, duration: 218),

        // The Weeknd - After Hours
        MockSong(title: "Blinding Lights", artist: "The Weeknd", album: "After Hours", playCount: 612, duration: 200),
        MockSong(title: "Save Your Tears", artist: "The Weeknd", album: "After Hours", playCount: 445, duration: 215),

        // Olivia Rodrigo - SOUR
        MockSong(title: "drivers license", artist: "Olivia Rodrigo", album: "SOUR", playCount: 389, duration: 242),
        MockSong(title: "good 4 u", artist: "Olivia Rodrigo", album: "SOUR", playCount: 423, duration: 178),
        MockSong(title: "deja vu", artist: "Olivia Rodrigo", album: "SOUR", playCount: 298, duration: 215),

        // Queen - A Night at the Opera
        MockSong(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", playCount: 534, duration: 354),

        // Queen - Greatest Hits (DUPLICATE)
        MockSong(title: "Bohemian Rhapsody", artist: "Queen", album: "Greatest Hits", playCount: 178, duration: 354),

        // Arctic Monkeys - AM
        MockSong(title: "Do I Wanna Know?", artist: "Arctic Monkeys", album: "AM", playCount: 387, duration: 272),
        MockSong(title: "R U Mine?", artist: "Arctic Monkeys", album: "AM", playCount: 334, duration: 201),

        // Dua Lipa - Future Nostalgia
        MockSong(title: "Don't Start Now", artist: "Dua Lipa", album: "Future Nostalgia", playCount: 456, duration: 183),
        MockSong(title: "Levitating", artist: "Dua Lipa", album: "Future Nostalgia", playCount: 523, duration: 203),

        // Low play count songs (to show variety in sorting)
        MockSong(title: "New Discovery", artist: "Indie Artist", album: "Fresh Sounds", playCount: 5, duration: 195),
        MockSong(title: "Recently Added", artist: "Emerging Band", album: "Debut Album", playCount: 12, duration: 224),
        MockSong(title: "Hidden Gem", artist: "Underground Artist", album: "Lost Tracks", playCount: 28, duration: 267),
    ]

    /// Get all unique albums for artwork fetching
    static var uniqueAlbums: [(artist: String, album: String)] {
        var seen = Set<String>()
        var albums: [(String, String)] = []

        for song in songs {
            let key = "\(song.artist)|\(song.album)"
            if !seen.contains(key) {
                seen.insert(key)
                albums.append((song.artist, song.album))
            }
        }

        return albums
    }
}
#endif
