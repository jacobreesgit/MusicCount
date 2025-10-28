import SwiftUI

struct PlayerTabView: View {
    @Environment(MusicPlayerService.self) private var playerService

    var body: some View {
        NavigationStack {
            if playerService.currentSession != nil {
                PlayerView()
            } else {
                emptyStateView
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundStyle(.secondary.opacity(0.5))

            Text("No Active Session")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Select songs in Library to match play counts")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}
