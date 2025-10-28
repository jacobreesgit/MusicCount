import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var playerService = MusicPlayerService()

    public var body: some View {
        TabView(selection: $selectedTab) {
            LibraryTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Library", systemImage: "music.note.list")
                }
                .tag(0)

            PlayerTabView()
                .tabItem {
                    Label("Player", systemImage: "play.circle.fill")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .environment(playerService)
    }

    public init() {}
}
