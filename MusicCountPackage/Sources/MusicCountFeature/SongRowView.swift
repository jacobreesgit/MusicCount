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
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label("\(song.playCount) plays", systemImage: "play.circle.fill")
                    .font(.caption)
                    .foregroundStyle(song.playCount > 0 ? .blue : .secondary)
            }

            Spacer()

            // Selection Badge
            if let slot = selectionSlot {
                SelectionBadge(slot: slot)
            }
        }
        .padding(.vertical, 4)
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
