import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var playerService = MusicPlayerService()
    @State private var suggestionsService = SuggestionsService()

    public var body: some View {
        TabView(selection: $selectedTab) {
            LibraryTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Library", systemImage: "music.note.list")
                }
                .tag(0)

            SuggestionsTabView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Suggestions", systemImage: "lightbulb.fill")
                }
                .badge(suggestionsService.activeSuggestions.count)
                .tag(1)

            PlayerTabView()
                .tabItem {
                    Label("Player", systemImage: "play.circle.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .environment(playerService)
        .environment(suggestionsService)
    }

    public init() {}
}
