import SwiftUI

struct SuggestionCard: View {
    let suggestion: Suggestion
    let onDismissSong: (SongInfo) -> Void
    let onDismissGroup: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text(suggestion.sharedTitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(suggestion.versionCount)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)

                // All versions using SongRowView
                ForEach(suggestion.songs) { song in
                    Group {
                        if suggestion.canDismissIndividualSongs {
                            // When 3+ songs: Allow individual row swipe
                            SongRowView(song: song, selectionSlot: nil)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        onDismissSong(song)
                                    } label: {
                                        Label("Dismiss", systemImage: "xmark.circle")
                                    }
                                }
                        } else {
                            // When 2 songs: No individual swipe
                            SongRowView(song: song, selectionSlot: nil)
                        }
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
