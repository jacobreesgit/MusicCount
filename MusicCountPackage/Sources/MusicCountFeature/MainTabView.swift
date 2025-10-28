import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0

    public var body: some View {
        TabView(selection: $selectedTab) {
            LibraryTabView()
                .tabItem {
                    Label("Library", systemImage: "music.note.list")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
    }

    public init() {}
}
