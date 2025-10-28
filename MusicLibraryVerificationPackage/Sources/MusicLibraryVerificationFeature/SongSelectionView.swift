import SwiftUI

struct SongSelectionView: View {
    let songs: [SongInfo]
    let selectionTitle: String
    @Binding var selectedSong: SongInfo?
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var sortOption: SortOption = .playCountDescending

    var body: some View {
        List(filteredAndSortedSongs) { song in
            Button {
                selectedSong = song
                dismiss()
            } label: {
                SongRowView(song: song)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select \(song.title) by \(song.artist), \(song.playCount) plays")
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search songs")
        .navigationTitle(selectionTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }

            if selectedSong != nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        selectedSong = nil
                        dismiss()
                    }
                }
            }
        }
    }

    private var filteredAndSortedSongs: [SongInfo] {
        var filtered = songs

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { song in
                song.title.localizedStandardContains(searchText) ||
                song.artist.localizedStandardContains(searchText) ||
                song.album.localizedStandardContains(searchText)
            }
        }

        // Apply sorting
        return sortOption.sorted(filtered)
    }
}
