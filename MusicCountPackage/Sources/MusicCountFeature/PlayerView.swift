import SwiftUI

struct PlayerView: View {
    @Environment(MusicPlayerService.self) private var playerService

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if let session = playerService.currentSession, session.isCompleted {
                completionView(session: session)
            } else {
                playerContent(session: playerService.currentSession)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Clear Session") {
                    playerService.cancelSession()
                }
                .disabled(playerService.currentSession == nil)
            }
        }
    }

    // MARK: - Player Content

    @ViewBuilder
    private func playerContent(session: MatchingSession?) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // Song Info
            VStack(spacing: 8) {
                Text(session?.songTitle ?? "No Active Session")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(session?.songArtist ?? "Select songs to begin")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            // Progress Info
            VStack(spacing: 16) {
                // Play progress
                VStack(spacing: 8) {
                    Text("Play \((session?.completedPlays ?? 0) + 1) of \(session?.targetPlays ?? 0)")
                        .font(.headline)
                        .fontWeight(.semibold)

                    ProgressView(value: session?.progress ?? 0.0)
                        .progressViewStyle(.linear)
                        .frame(height: 8)
                        .tint(.blue)
                }

                // Playback time
                if case .playing(let currentTime, let duration) = playerService.playerState {
                    VStack(spacing: 8) {
                        Slider(value: .constant(currentTime), in: 0...duration)
                            .disabled(true)

                        HStack {
                            Text(timeString(currentTime))
                                .font(.caption)
                                .monospacedDigit()
                            Spacer()
                            Text(timeString(duration))
                                .font(.caption)
                                .monospacedDigit()
                        }
                        .foregroundStyle(.secondary)
                    }
                } else if case .paused(let currentTime, let duration) = playerService.playerState {
                    VStack(spacing: 8) {
                        Slider(value: .constant(currentTime), in: 0...duration)
                            .disabled(true)

                        HStack {
                            Text(timeString(currentTime))
                                .font(.caption)
                                .monospacedDigit()
                            Spacer()
                            Text(timeString(duration))
                                .font(.caption)
                                .monospacedDigit()
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

            // Playback Controls
            HStack(spacing: 40) {
                Button {
                    playerService.skipToNextPlay()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel("Skip to next play")

                Button {
                    if case .playing = playerService.playerState {
                        playerService.pause()
                    } else {
                        playerService.play()
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel(isPlaying ? "Pause" : "Play")

                Button {
                    playerService.skipToNextPlay()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel("Skip to next play")
            }
            .disabled(session == nil)
            .opacity(session == nil ? 0.5 : 1.0)

            // Play Count Info
            VStack(spacing: 12) {
                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Plays")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(session?.startingSystemPlayCount ?? 0)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("In-App Plays")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("+\(session?.completedPlays ?? 0)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.blue)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Target")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(session?.targetPlays ?? 0)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.green)
                    }
                }

                Text("Note: System play count updates when app fully closes and reopens")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .padding()
    }

    // MARK: - Completion View

    @ViewBuilder
    private func completionView(session: MatchingSession) -> some View {
        VStack(spacing: 32) {
            Spacer()

            // Success Animation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: true)

            VStack(spacing: 12) {
                Text("Goal Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("You've played \"\(session.songTitle)\" \(session.completedPlays) times")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                Text("System play count will update when you:")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    Label("Fully close this app", systemImage: "xmark.app")
                    Label("Reopen the app", systemImage: "arrow.clockwise")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

            Button {
                playerService.completeSession()
            } label: {
                Label("Done", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private var isPlaying: Bool {
        if case .playing = playerService.playerState {
            return true
        }
        return false
    }

    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
