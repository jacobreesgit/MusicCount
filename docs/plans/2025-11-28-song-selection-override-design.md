# Song Selection Override for Match/Add Modes

## Problem

Currently, Match and Add modes automatically queue the song with fewer plays. Users cannot override this to queue the higher-play-count song instead.

## Solution

Allow users to tap either song card in ComparisonView to select which song gets queued. The lower-play-count song remains the default selection.

## Visual Design

### Selected Card
- Amber/gold glowing border ring (`#F5A623`)
- Small checkmark badge in corner with label "Queuing this song"
- Full opacity (1.0)

### Unselected Card
- No border ring
- Slightly dimmed opacity (0.85)
- Retains existing blue (Song 1) or green (Song 2) tint

### Transitions
- Ring animates between cards (0.3s ease-out)
- Checkmark fades out/in with spring animation
- Light haptic feedback on selection change

## Interaction

- Tap anywhere on a song card to select it
- Match/Add button text updates to reflect selected song
- Play count calculations adjust based on selection

### Edge Cases
- **Equal play counts**: Neither card pre-selected, prompt shown: "Tap a song to queue"
- **First use**: Tooltip appears once: "Tap either song to change which one gets queued"

## Button Text Updates

When lower-play song selected (default):
- Match: "Add [Title] X times to reach Y plays"
- Add: "Add [Title] X times to reach Y plays"

When higher-play song selected:
- Match: "Add [Title] X times to extend lead to Y plays"
- Add: "Add [Title] X times to reach Y plays"

## State Management

```swift
@State private var selectedSongForQueue: SongInfo?

// Initialize to lower-play-count song
.task {
    selectedSongForQueue = song1.playCount <= song2.playCount ? song1 : song2
}

// Computed helpers
var isSong1Selected: Bool {
    selectedSongForQueue?.id == song1.id
}
```

## File Changes

- `ComparisonView.swift`: All changes contained here
  - Add selection state
  - Add `.songCardSelection(isSelected:)` view modifier
  - Update button text and calculations
  - Add first-use tooltip logic

## Implementation Notes

- Store "has seen tooltip" flag in UserDefaults via AppStorage
- Use `withAnimation(.easeOut(duration: 0.3))` for ring transitions
- Use `UIImpactFeedbackGenerator(style: .light)` for haptics
