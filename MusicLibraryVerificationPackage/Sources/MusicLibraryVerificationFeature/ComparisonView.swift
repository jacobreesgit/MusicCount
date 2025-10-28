import SwiftUI

struct ComparisonView: View {
    let song1: SongInfo
    let song2: SongInfo

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with comparison summary
                comparisonSummary

                Divider()

                // Song 1 Details
                songCard(song: song1, label: "Song 1", color: .blue)

                // VS Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.secondary.opacity(0.3))

                    Text("VS")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)

                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.secondary.opacity(0.3))
                }
                .padding(.vertical, 8)

                // Song 2 Details
                songCard(song: song2, label: "Song 2", color: .green)

                // Play Count Comparison
                playCountComparisonSection
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
        VStack(alignment: .leading, spacing: 12) {
            // Label
            HStack {
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(color.gradient, in: Capsule())

                Spacer()

                if song.hasAssetURL {
                    Label("Local", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            // Song Info
            VStack(alignment: .leading, spacing: 8) {
                Text(song.title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !song.album.isEmpty && song.album != "Unknown Album" {
                    Label(song.album, systemImage: "opticaldisc")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Play Count Badge
            HStack {
                Image(systemName: "play.circle.fill")
                    .foregroundStyle(color)
                Text("\(song.playCount)")
                    .font(.title)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                Text("plays")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
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
}
