import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var queueService = AppleMusicQueueService()
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

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .environment(queueService)
        .environment(suggestionsService)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    public init() {}
}
