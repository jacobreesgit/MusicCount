#if DEBUG
import Foundation

/// Mock implementation of MusicLibraryService for App Store screenshots
/// Returns curated mock data with real album artwork from iTunes API
/// Subclasses the real service to allow seamless type compatibility
@MainActor
final class MockMusicLibraryService: MusicLibraryService {
    private let generator = MockDataGenerator()

    override init() {
        super.init()
        // Set to authorized immediately to skip permission flow
        self.authorizationState = .authorized
        NSLog("🎭 MockMusicLibraryService initialized")
        NSLog("⚠️ Using mock data for App Store screenshots")
    }

    /// Check authorization status (always returns authorized in mock mode)
    override func checkAuthorizationStatus() {
        authorizationState = .authorized
    }

    /// Request authorization (always succeeds in mock mode)
    override func requestAuthorization() async {
        authorizationState = .authorized
    }

    /// Load mock music library with real album artwork
    override func loadMusicLibrary() async {
        NSLog("🎭 MockMusicLibraryService: loadMusicLibrary() called")
        loadingState = .loading

        // Simulate brief loading time for realistic feel
        try? await Task.sleep(for: .milliseconds(500))

        // Generate mock songs with real album artwork
        NSLog("🎭 MockMusicLibraryService: Generating mock library...")
        let songs = await generator.generateMockLibrary()
        NSLog("🎭 MockMusicLibraryService: Generated \(songs.count) songs")

        if songs.isEmpty {
            NSLog("❌ MockMusicLibraryService: No songs generated!")
            loadingState = .error("No mock songs generated")
        } else {
            NSLog("✅ MockMusicLibraryService: Loading \(songs.count) songs into state")
            loadingState = .loaded(songs)
        }
    }
}
#endif
