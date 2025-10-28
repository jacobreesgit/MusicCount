import MediaPlayer
import Observation
import AVFoundation
import Combine

@MainActor
@Observable
final class MusicPlayerService {
    enum PlayerState: Sendable {
        case idle
        case loading
        case playing(currentTime: TimeInterval, duration: TimeInterval)
        case paused(currentTime: TimeInterval, duration: TimeInterval)
        case error(String)
    }

    private(set) var playerState: PlayerState = .idle
    private(set) var currentSession: MatchingSession?

    private let player = MPMusicPlayerController.applicationMusicPlayer
    private var timeObserver: AnyCancellable?
    private let sessionKey = "MatchingSession"

    init() {
        configureAudioSession()
        setupNotifications()
        loadSession()
    }

    // MARK: - Session Management

    func startMatchingSession(
        song: SongInfo,
        targetPlays: Int,
        mode: MatchingSession.Mode
    ) {
        let session = MatchingSession(
            songId: song.id,
            songTitle: song.title,
            songArtist: song.artist,
            targetPlays: targetPlays,
            startingSystemPlayCount: song.playCount,
            mode: mode
        )

        currentSession = session
        saveSession()
        startPlaying(song: song)
    }

    func cancelSession() {
        stopPlaying()
        currentSession = nil
        clearSession()
    }

    func completeSession() {
        stopPlaying()
        currentSession = nil
        clearSession()
    }

    // MARK: - Playback Controls

    private func startPlaying(song: SongInfo) {
        // Find the song in MPMediaLibrary
        let query = MPMediaQuery.songs()
        guard let items = query.items,
              let mediaItem = items.first(where: { $0.persistentID == song.id }) else {
            playerState = .error("Song not found in library")
            return
        }

        playerState = .loading

        // Activate audio session before playing
        activateAudioSession()

        // Set up the player with this song
        let collection = MPMediaItemCollection(items: [mediaItem])
        player.setQueue(with: collection)
        player.play()

        startTimeObserver()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func skipToNextPlay() {
        // Complete current play and start next
        if var session = currentSession {
            session.completedPlays += 1
            session.lastPlayedAt = Date()
            currentSession = session
            saveSession()

            if session.isCompleted {
                // Session complete!
                stopPlaying()
                playerState = .idle
            } else {
                // Restart the song for next play
                player.skipToBeginning()
                player.play()
            }
        }
    }

    private func stopPlaying() {
        player.stop()
        player.endGeneratingPlaybackNotifications()
        timeObserver?.cancel()
        timeObserver = nil
        playerState = .idle

        // Deactivate audio session to allow other audio to resume
        deactivateAudioSession()
    }

    // MARK: - Time Observer

    private func startTimeObserver() {
        // Update every 0.1 seconds
        timeObserver = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updatePlaybackTime()
                }
            }
    }

    private nonisolated func updatePlaybackTime() {
        Task { @MainActor in
            let currentTime = player.currentPlaybackTime
            let duration = player.nowPlayingItem?.playbackDuration ?? 0

            switch player.playbackState {
            case .playing:
                playerState = .playing(currentTime: currentTime, duration: duration)
            case .paused:
                playerState = .paused(currentTime: currentTime, duration: duration)
            case .stopped:
                playerState = .idle
            default:
                break
            }
        }
    }

    // MARK: - Notifications

    private nonisolated func setupNotifications() {
        Task { @MainActor in
            NotificationCenter.default.addObserver(
                forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
                object: player,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.handleSongDidFinish()
                }
            }

            NotificationCenter.default.addObserver(
                forName: .MPMusicPlayerControllerPlaybackStateDidChange,
                object: player,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.updatePlaybackTime()
                }
            }

            player.beginGeneratingPlaybackNotifications()
        }
    }

    private func handleSongDidFinish() {
        // Song finished, auto-advance to next play
        skipToNextPlay()
    }

    // MARK: - Audio Session

    private nonisolated func configureAudioSession() {
        do {
            // Configure for exclusive playback - takes over audio when playing
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default
            )
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private nonisolated func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }

    private nonisolated func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }

    // MARK: - Persistence

    private func saveSession() {
        guard let session = currentSession else { return }
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: sessionKey)
        }
    }

    private func loadSession() {
        guard let data = UserDefaults.standard.data(forKey: sessionKey),
              let session = try? JSONDecoder().decode(MatchingSession.self, from: data) else {
            return
        }
        currentSession = session
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    // Cleanup happens automatically:
    // - AnyCancellable.cancel() is called when timeObserver is deallocated
    // - player.endGeneratingPlaybackNotifications() is called in stopPlaying()
}
