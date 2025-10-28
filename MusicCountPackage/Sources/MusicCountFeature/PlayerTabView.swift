import SwiftUI

struct PlayerTabView: View {
    @Environment(MusicPlayerService.self) private var playerService

    var body: some View {
        NavigationStack {
            PlayerView()
        }
    }
}
