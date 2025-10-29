import Foundation

/// Factory to create the appropriate music library service based on launch arguments
@MainActor
enum MusicLibraryServiceFactory {
    /// Creates either real or mock service based on launch arguments
    /// Use "-MockData" launch argument to enable mock mode for screenshots
    static func create() -> MusicLibraryService {
        let args = ProcessInfo.processInfo.arguments
        NSLog("🔍 Launch arguments: \(args.joined(separator: ", "))")

        #if DEBUG
        if args.contains("-MockData") {
            NSLog("🎭 Mock mode enabled - using MockMusicLibraryService")
            return MockMusicLibraryService()
        }
        #endif
        NSLog("📱 Using real MusicLibraryService (no -MockData found)")
        return MusicLibraryService()
    }
}
