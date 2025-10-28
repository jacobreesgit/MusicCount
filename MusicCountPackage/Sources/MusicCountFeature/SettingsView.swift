import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            // About Section
            Section {
                VStack(spacing: 16) {
                    // App Icon
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
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
    }

    // MARK: - Helper Properties

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
