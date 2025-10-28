import SwiftUI

struct SettingsView: View {
    @Environment(SuggestionsService.self) private var suggestionsService
    @State private var showingResetAlert = false

    var body: some View {
        Form {
            // About Section
            Section {
                VStack(spacing: 16) {
                    // App Icon
                    Image(systemName: "music.note.list")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue.gradient)
                        .padding(.top, 8)

                    // App Name
                    Text("MusicCount")
                        .font(.title2)
                        .fontWeight(.semibold)

                    // Tagline
                    Text("Track and compare your music play counts")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section {
                HStack {
                    Text("Version")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("App Information")
            }

            Section {
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    Label("Reset Dismissed Suggestions", systemImage: "arrow.counterclockwise.circle")
                }
            } header: {
                Text("Suggestions")
            } footer: {
                Text("All previously dismissed songs and suggestion groups will appear again in the Suggestions tab.")
            }

            Section {
                Link(destination: URL(string: "mailto:jacobrees@me.com")!) {
                    HStack {
                        Label("Send Feedback", systemImage: "envelope")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Support")
            }

            Section {
                VStack(spacing: 8) {
                    Text("Made with ♥︎ for music lovers")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Text("© 2025 MusicCount")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .alert("Reset Dismissed Suggestions?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                suggestionsService.resetDismissals()
            }
        } message: {
            Text("All previously dismissed songs and suggestion groups will appear again in the Suggestions tab.")
        }
    }

    // MARK: - Helper Properties

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
