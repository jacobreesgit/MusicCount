import SwiftUI

struct ComparisonView: View {
    let song1: SongInfo
    let song2: SongInfo
    @Binding var showingComparison: Bool
    @Binding var selectedTab: Int

    @Environment(AppleMusicQueueService.self) private var queueService
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var queuedCount = 0
    @State private var selectedSongForQueue: SongInfo?
    @AppStorage(StorageKeys.hasSeenSongSelectionTooltip) private var hasSeenTooltip = false
    @State private var showTooltip = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with comparison summary
                VStack(spacing: 12) {
                    comparisonSummary
                        .accessibilityElement(children: .combine)

                    if showTooltip {
                        tooltipView
                    }
                }

                Divider()

                // Side-by-side comparison cards
                HStack(spacing: 0) {
                    // Song 1 Card
                    songCard(song: song1, label: "Song 1", color: .blue, isSelected: isSong1Selected)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Song 1: \(song1.title) by \(song1.artist), \(song1.playCount) plays\(isSong1Selected ? ", selected for queuing" : "")")
                        .accessibilityHint("Tap to select this song for queuing")

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
                    songCard(song: song2, label: "Song 2", color: .green, isSelected: isSong2Selected)
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("Song 2: \(song2.title) by \(song2.artist), \(song2.playCount) plays\(isSong2Selected ? ", selected for queuing" : "")")
                        .accessibilityHint("Tap to select this song for queuing")
                }
                .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.5), trigger: selectedSongForQueue?.id)

                // Matching Buttons
                matchingButtonsSection
            }
            .padding()
        }
        .navigationTitle("Comparison")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Added to Apple Music Queue", isPresented: $showingSuccessAlert) {
            Button("OK") {
                showingComparison = false
            }
        } message: {
            Text("\(queuedCount) copies of \(selectedSong.title) have been added to your Apple Music queue. Open the Music app to start playback.")
        }
        .alert("Unable to Add to Queue", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            // Default to lower play count song
            if song1.playCount == song2.playCount {
                // Equal plays - no default selection, user must choose
                selectedSongForQueue = nil
            } else {
                selectedSongForQueue = song1.playCount <= song2.playCount ? song1 : song2
            }

            // Show tooltip on first use
            if !hasSeenTooltip {
                showTooltip = true
            }
        }
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

    private func songCard(song: SongInfo, label: String, color: Color, isSelected: Bool) -> some View {
        VStack(alignment: .center, spacing: 12) {
            // Label with selection badge
            HStack(spacing: 6) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(selectionRingColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
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
                    .foregroundStyle(color.gradient)

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
        .opacity(isSelected || selectedSongForQueue == nil ? 1.0 : 0.85)
        .contentShape(Rectangle())
        .onTapGesture {
            selectSong(song)
        }
    }

    // MARK: - Tooltip

    private var tooltipView: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap.fill")
                .font(.subheadline)
            Text("Tap either song to change which one gets queued")
                .font(.subheadline)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.8), in: Capsule())
        .padding(.bottom, 8)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                showTooltip = false
            }
            hasSeenTooltip = true
        }
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

    // MARK: - Selection State

    private var isSong1Selected: Bool {
        selectedSongForQueue?.id == song1.id
    }

    private var isSong2Selected: Bool {
        selectedSongForQueue?.id == song2.id
    }

    private var selectedSong: SongInfo {
        selectedSongForQueue ?? (song1.playCount <= song2.playCount ? song1 : song2)
    }

    private var otherSong: SongInfo {
        selectedSong.id == song1.id ? song2 : song1
    }

    private var selectedSongLabel: String {
        if song1.title.lowercased() == song2.title.lowercased() &&
           song1.artist.lowercased() == song2.artist.lowercased() {
            // Same title and artist, need to distinguish by number
            let songNumber = selectedSong.id == song1.id ? "Song 1" : "Song 2"
            return "\(selectedSong.title) (\(songNumber))"
        } else {
            // Different songs, just show the title
            return selectedSong.title
        }
    }

    private func selectSong(_ song: SongInfo) {
        withAnimation(.easeOut(duration: 0.3)) {
            selectedSongForQueue = song
        }

        // Dismiss tooltip on first selection
        if showTooltip {
            withAnimation(.easeOut(duration: 0.2)) {
                showTooltip = false
            }
            hasSeenTooltip = true
        }
    }

    // Selection ring color
    private let selectionRingColor = Color.white

    // MARK: - Matching Buttons Section

    private var matchingButtonsSection: some View {
        VStack(spacing: 16) {
            Text("Add to Apple Music Queue")
                .font(.headline)

            // Show prompt if no song selected (equal play counts)
            if selectedSongForQueue == nil {
                Text("Tap a song above to select which one to queue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }

            VStack(spacing: 12) {
                // Match Mode Button
                // Disabled if: no selection, or selected song already has more/equal plays
                let matchPlaysNeeded = otherSong.playCount - selectedSong.playCount
                let isMatchModeDisabled = selectedSongForQueue == nil || matchPlaysNeeded <= 0
                Button {
                    do {
                        try queueService.addToQueue(song: selectedSong, count: matchPlaysNeeded)
                        queuedCount = matchPlaysNeeded
                        showingSuccessAlert = true
                    } catch let error as AppleMusicQueueService.QueueError {
                        errorMessage = error.localizedDescription
                        showingErrorAlert = true
                    } catch {
                        errorMessage = "An unexpected error occurred. Please try again."
                        showingErrorAlert = true
                    }
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

                        if selectedSongForQueue == nil {
                            Text("Select a song to enable")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        } else if matchPlaysNeeded <= 0 {
                            Text("Selected song already has more plays")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text("Add \(selectedSongLabel) \(matchPlaysNeeded) times to reach \(otherSong.playCount) plays")
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
                // Adds the selected song as many times as the other song has plays
                let addModeTargetPlays = otherSong.playCount
                let isAddModeDisabled = selectedSongForQueue == nil || addModeTargetPlays == 0
                Button {
                    do {
                        try queueService.addToQueue(song: selectedSong, count: addModeTargetPlays)
                        queuedCount = addModeTargetPlays
                        showingSuccessAlert = true
                    } catch let error as AppleMusicQueueService.QueueError {
                        errorMessage = error.localizedDescription
                        showingErrorAlert = true
                    } catch {
                        errorMessage = "An unexpected error occurred. Please try again."
                        showingErrorAlert = true
                    }
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

                        if selectedSongForQueue == nil {
                            Text("Select a song to enable")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        } else if isAddModeDisabled {
                            Text("Other song has no plays to add")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        } else {
                            Text("Add \(selectedSongLabel) \(addModeTargetPlays) times to reach \(selectedSong.playCount + addModeTargetPlays) plays")
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
