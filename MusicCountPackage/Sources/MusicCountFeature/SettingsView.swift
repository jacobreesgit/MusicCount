import SwiftUI

struct SettingsView: View {
    @Environment(SuggestionsService.self) private var suggestionsService
    @State private var showingResetAlert = false
    @AppStorage("queueBehavior") private var queueBehavior: QueueBehavior = .insertNext

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
                Picker(selection: $queueBehavior) {
                    ForEach(QueueBehavior.allCases) { behavior in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: behavior.icon)
                                Text(behavior.displayName)
                                    .font(.body)
                            }
                        }
                        .tag(behavior)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            } header: {
                Text("Queue Behavior")
            } footer: {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose how songs are added to your Apple Music queue when matching play counts.")

                    Text(queueBehavior.description)
                }
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
}
