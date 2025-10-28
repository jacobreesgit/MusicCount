import SwiftUI

struct ComparisonView: View {
    let song1: SongInfo
    let song2: SongInfo
    @Binding var showingComparison: Bool
    @Binding var selectedTab: Int

    @Environment(MusicPlayerService.self) private var playerService

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with comparison summary
                comparisonSummary
                    .accessibilityElement(children: .combine)

                Divider()

                // Side-by-side comparison cards
                HStack(spacing: 0) {
                    // Song 1 Card
                    songCard(song: song1, label: "Song 1", color: .blue)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Song 1: \(song1.title) by \(song1.artist), \(song1.playCount) plays")

                    // VS Divider
                    VStack(spacing: 4) {
                        Rectangle()
                            .frame(width: 1)
                            .foregroundStyle(.secondary.opacity(0.3))

                        Text("VS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)

                        Rectangle()
                            .frame(width: 1)
                            .foregroundStyle(.secondary.opacity(0.3))
                    }
                    .frame(width: 60)
                    .accessibilityHidden(true)

                    // Song 2 Card
                    songCard(song: song2, label: "Song 2", color: .green)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Song 2: \(song2.title) by \(song2.artist), \(song2.playCount) plays")
                }

                // Matching Buttons
                matchingButtonsSection
            }
            .padding()
        }
        .navigationTitle("Comparison")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Comparison Summary

    private var comparisonSummary: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue.gradient)

            Text("Play Count Comparison")
                .font(.title2)
                .fontWeight(.semibold)

            if difference != 0 {
                Text(winnerText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Both songs have the same play count!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Song Card

    private func songCard(song: SongInfo, label: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: 12) {
            // Label
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(color.gradient, in: Capsule())

            // Song Info
            VStack(alignment: .center, spacing: 6) {
                Text(song.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)

                Text(song.artist)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            // Play Count Badge
            VStack(spacing: 4) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(color)

                Text("\(song.playCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                Text("plays")
                    .font(.caption2)
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            ZStack {
                if let artworkImage = song.artworkImage {
                    Image(uiImage: artworkImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
                Rectangle()
                    .fill(.black.opacity(0.55))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Play Count Comparison

    private var playCountComparisonSection: some View {
        VStack(spacing: 16) {
            Text("Play Count Analysis")
                .font(.headline)

            VStack(spacing: 12) {
                // Difference
                HStack {
                    Text("Difference:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(abs(difference)) plays")
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                }

                // Percentage (if both have plays)
                if song1.playCount > 0 && song2.playCount > 0 {
                    HStack {
                        Text("Ratio:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(ratioText)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                }

                // Visual comparison bars
                if song1.playCount > 0 || song2.playCount > 0 {
                    visualComparison
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var visualComparison: some View {
        VStack(spacing: 8) {
            // Song 1 bar
            HStack {
                Text("Song 1")
                    .font(.caption)
                    .frame(width: 50, alignment: .leading)

                GeometryReader { geometry in
                    Rectangle()
                        .fill(.blue.gradient)
                        .frame(width: barWidth(for: song1.playCount, maxWidth: geometry.size.width))
                }
                .frame(height: 20)
            }

            // Song 2 bar
            HStack {
                Text("Song 2")
                    .font(.caption)
                    .frame(width: 50, alignment: .leading)

                GeometryReader { geometry in
                    Rectangle()
                        .fill(.green.gradient)
                        .frame(width: barWidth(for: song2.playCount, maxWidth: geometry.size.width))
                }
                .frame(height: 20)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Computed Properties

    private var difference: Int {
        song1.playCount - song2.playCount
    }

    private var winnerText: String {
        if difference > 0 {
            return "Song 1 has been played \(difference) more times"
        } else {
            return "Song 2 has been played \(abs(difference)) more times"
        }
    }

    private var ratioText: String {
        let higher = max(song1.playCount, song2.playCount)
        let lower = min(song1.playCount, song2.playCount)

        guard lower > 0 else { return "N/A" }

        let ratio = Double(higher) / Double(lower)
        return String(format: "%.1f:1", ratio)
    }

    private func barWidth(for playCount: Int, maxWidth: CGFloat) -> CGFloat {
        let maxPlayCount = max(song1.playCount, song2.playCount)
        guard maxPlayCount > 0 else { return 0 }

        let percentage = CGFloat(playCount) / CGFloat(maxPlayCount)
        return maxWidth * percentage
    }

    private var lowerSong: SongInfo {
        song1.playCount < song2.playCount ? song1 : song2
    }

    private var higherSong: SongInfo {
        song1.playCount > song2.playCount ? song1 : song2
    }

    private var lowerSongLabel: String {
        if song1.title.lowercased() == song2.title.lowercased() &&
           song1.artist.lowercased() == song2.artist.lowercased() {
            // Same title and artist, need to distinguish by number
            let songNumber = lowerSong.id == song1.id ? "Song 1" : "Song 2"
            return "\(lowerSong.title) (\(songNumber))"
        } else {
            // Different songs, just show the title
            return lowerSong.title
        }
    }

    // MARK: - Matching Buttons Section

    private var matchingButtonsSection: some View {
        VStack(spacing: 16) {
            Text("Match Play Counts")
                .font(.headline)

            VStack(spacing: 12) {
                // Match Mode Button
                let isMatchModeDisabled = difference == 0
                Button {
                    let targetPlays = higherSong.playCount
                    let playsNeeded = targetPlays - lowerSong.playCount
                    playerService.startMatchingSession(
                        song: lowerSong,
                        targetPlays: playsNeeded,
                        mode: .match
                    )
                    showingComparison = false
                    selectedTab = 1
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "equal.circle.fill")
                                .font(.title2)
                            Text("Match Mode")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if isMatchModeDisabled {
                            Text("Songs already have matching play counts")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text("Play \(lowerSongLabel) \(higherSong.playCount - lowerSong.playCount) times to reach \(higherSong.playCount) plays")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isMatchModeDisabled ? .gray.opacity(0.1) : .blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isMatchModeDisabled)
                .opacity(isMatchModeDisabled ? 0.6 : 1.0)

                // Add Mode Button
                let isAddModeDisabled = higherSong.playCount == 0
                let addModeTargetPlays = higherSong.playCount
                Button {
                    playerService.startMatchingSession(
                        song: lowerSong,
                        targetPlays: addModeTargetPlays,
                        mode: .add
                    )
                    showingComparison = false
                    selectedTab = 1
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add Mode")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if isAddModeDisabled {
                            Text("No plays to add")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text("Play \(lowerSongLabel) \(addModeTargetPlays) times to reach \(lowerSong.playCount + addModeTargetPlays) plays")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(isAddModeDisabled ? .gray.opacity(0.1) : .green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isAddModeDisabled)
                .opacity(isAddModeDisabled ? 0.6 : 1.0)
            }

            Text("Note: Play counts update when you fully close and reopen the app")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
