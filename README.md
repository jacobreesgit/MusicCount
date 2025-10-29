# 🎵 MusicCount

**Match Your Music Plays**

Track and sync play counts across duplicate songs in your Apple Music library.

---

## Overview

MusicCount helps you track and match play counts across duplicate songs in your Apple Music library. Whether you have the same song across different albums, compilations, or singles, MusicCount identifies mismatched play counts and helps you sync them.

**Privacy First:** All data stays on your device. No servers, no tracking, no data collection.

---

## Features

### 📚 View Your Library
Browse your entire music collection with play counts. Sort by:
- **Play Count:** See which songs you've played most
- **Title:** Alphabetical by song name
- **Artist:** Alphabetical by artist name
- **Album:** Alphabetical by album name

### 💡 Smart Suggestions
Automatically discover duplicate songs with mismatched play counts across your library. Perfect for:
- Songs appearing on multiple albums
- Singles vs. album versions
- Compilation appearances

### 🔄 Queue & Match
Queue songs multiple times to match play counts between different versions of the same track. Customizable queue behavior:
- **Insert Next:** Add songs after current track
- **Replace Queue:** Clear queue and add songs
- **Play Immediately:** Start playing right away

### 🔒 Privacy First
- All data stays on your device
- No external servers or data collection
- No analytics or tracking
- No advertising
- Full control over your music library

### ⚙️ Customizable
Configure queue behavior, sorting preferences, and more to match your workflow.

### 📱 Native iOS
Built with SwiftUI for a smooth, native iPhone experience.

---

## Requirements

- **iOS Version:** iOS 17.0 or later
- **Devices:** iPhone (Portrait orientation)
- **Permissions:** Media & Apple Music library access

---

## Documentation

- **Homepage:** [MusicCount Website](https://jacobreesgit.github.io/MusicCount/)
- **Privacy Policy:** [Read our Privacy Policy](https://jacobreesgit.github.io/MusicCount/privacy.html)
- **Support:** [Get Support](https://jacobreesgit.github.io/MusicCount/support.html)

---

## Screenshots

View screenshots in:
- `iPhone 14 Plus Screenshots/` - 6.5" display (1284 x 2778)
- `iPhone 15 Pro Max Screenshots/` - 6.7" display (1290 x 2796)

---

## Perfect For

- Music enthusiasts who want accurate play count statistics
- Anyone with duplicate songs across albums, compilations, or singles
- Users who want to maintain consistent play counts

---

## Technical Details

### Architecture

This project follows a **workspace + SPM package** architecture:

```
MusicCount/
├── MusicLibraryVerification.xcworkspace/    # Open this in Xcode
├── MusicCount.xcodeproj/                    # App shell project
├── MusicCount/                              # App target (minimal)
│   ├── Assets.xcassets/                     # App icon and assets
│   └── MusicCountApp.swift                  # App entry point
├── MusicCountPackage/                       # 🚀 Primary development area
│   ├── Package.swift                        # Package configuration
│   ├── Sources/MusicCountFeature/           # Feature code
│   └── Tests/MusicCountFeatureTests/        # Unit tests
└── docs/                                    # GitHub Pages website
    ├── index.html                           # Homepage
    ├── privacy.html                         # Privacy policy
    └── support.html                         # Support page
```

### Key Technologies

- **Swift 6.1+** with strict concurrency checking
- **SwiftUI** for all UI components
- **Swift Concurrency** (async/await, actors, @MainActor)
- **Swift Testing** framework for unit tests
- **MediaPlayer Framework** for music library access
- **MusicKit** for Apple Music integration

### Code Style

- **No ViewModels:** Pure SwiftUI state management with @State, @Observable, @Environment
- **Swift Concurrency:** Modern async/await throughout
- **Value Types:** Prefer structs over classes
- **Privacy by Design:** No data collection or external network calls

### Configuration

Build settings managed through XCConfig files in `Config/`:
- `Config/Shared.xcconfig` - Bundle ID, versions, deployment target, team ID
- `Config/Debug.xcconfig` - Debug-specific settings
- `Config/Release.xcconfig` - Release-specific settings
- `Config/MusicCount.entitlements` - App capabilities and entitlements

---

## Development

### Most development happens in the SPM package

Work in `MusicCountPackage/Sources/MusicCountFeature/` for:
- View components
- Business logic
- Data models
- Services

### Public API Requirements

Types exposed to the app target need `public` access:

```swift
public struct NewView: View {
    public init() {}

    public var body: some View {
        // Your view code
    }
}
```

### Testing

- **Unit Tests:** `MusicCountPackage/Tests/MusicCountFeatureTests/` (Swift Testing)
- **UI Tests:** `MusicCountUITests/` (XCUITest)
- Use Swift Testing's `@Test` macro and `#expect` assertions

---

## Privacy & Security

MusicCount is built with privacy as a core principle:

✅ **No Data Collection:** We don't collect, store, or transmit any user data
✅ **Local Processing:** All music library analysis happens on your device
✅ **No Analytics:** No tracking, no telemetry, no user behavior monitoring
✅ **No Third Parties:** No third-party SDKs or services
✅ **Open Source Architecture:** Review the code structure yourself

Read our full [Privacy Policy](https://jacobreesgit.github.io/MusicCount/privacy.html) for details.

---

## Support

Having issues or questions? Check out our [Support Page](https://jacobreesgit.github.io/MusicCount/support.html) for:
- Getting started guide
- Frequently asked questions
- Troubleshooting tips
- Contact information

---

## Building & Deployment

### Development Build
```bash
# Open workspace in Xcode
open MusicLibraryVerification.xcworkspace

# Or build from command line using XcodeBuildMCP
# Build for simulator
xcodebuild -workspace MusicLibraryVerification.xcworkspace \
           -scheme MusicCount \
           -destination 'platform=iOS Simulator,name=iPhone 16'

# Build for device (Release)
xcodebuild -workspace MusicLibraryVerification.xcworkspace \
           -scheme MusicCount \
           -configuration Release \
           -destination generic/platform=iOS
```

### App Store Submission
1. Open workspace in Xcode
2. Select **Any iOS Device** as destination
3. **Product** → **Archive**
4. Use Organizer to distribute to App Store Connect

---

## License

© 2025 MusicCount. All rights reserved.

---

## Contact

- **Email:** jacobrees@me.com
- **GitHub Issues:** [Report bugs or request features](https://github.com/jacobreesgit/MusicCount/issues)
- **Support Page:** [Get help](https://jacobreesgit.github.io/MusicCount/support.html)

---

## Acknowledgments

This project was scaffolded using [XcodeBuildMCP](https://github.com/cameroncooke/XcodeBuildMCP), which provides tools for AI-assisted iOS development workflows.

Built with ❤️ for music enthusiasts who care about their play count statistics.
