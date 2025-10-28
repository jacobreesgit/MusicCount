import SwiftUI

/// Reusable song row component displaying song information with optional selection badge
struct SongRowView: View {
    let song: SongInfo
    let selectionSlot: Int?

    init(song: SongInfo, selectionSlot: Int? = nil) {
        self.song = song
        self.selectionSlot = selectionSlot
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Album Artwork
            AlbumArtworkView(image: song.artworkImage)

            // Song Information
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                    Text("\(song.playCount) plays")
                }
                .font(.caption)
                .foregroundStyle(song.playCount > 0 ? .blue : .secondary)
            }

            Spacer()

            // Right Side: Duration or Badge
            ZStack {
                // Duration (shown when not selected)
                Text(song.formattedDuration)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .opacity(selectionSlot == nil ? 1 : 0)

                // Selection Badge (shown when selected)
                if let slot = selectionSlot {
                    SelectionBadge(slot: slot)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: selectionSlot)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(song.title) by \(song.artist), \(song.playCount) plays, duration \(song.accessibleDuration)")
    }
}

/// Album artwork view with placeholder for missing artwork
private struct AlbumArtworkView: View {
    let image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                // Placeholder for missing artwork
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    Image(systemName: "music.note")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(4)
        .clipped()
        .accessibilityHidden(true)
    }
}

/// Visual badge indicating song selection slot (1 or 2)
private struct SelectionBadge: View {
    let slot: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(slot == 1 ? Color.blue.gradient : Color.green.gradient)
                .frame(width: 32, height: 32)

            Text("\(slot)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
    }
}
