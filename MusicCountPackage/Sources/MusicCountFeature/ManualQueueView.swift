import SwiftUI

struct ManualQueueView: View {
    let song: SongInfo
    @Binding var showingManualQueue: Bool

    @Environment(AppleMusicQueueService.self) private var queueService
    @State private var numberOfPlays: Int = 10
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 50))
                            .foregroundStyle(.blue.gradient)

                        Text("Add to Queue")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Queue this song multiple times to increase play count")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .accessibilityElement(children: .combine)

                    Divider()

                    // Song Card
                    songCard
                        .accessibilityLabel("Selected song: \(song.title) by \(song.artist), current play count: \(song.playCount)")

                    // Number Input
                    numberInputSection

                    // Quick Amount Buttons
                    quickAmountButtons

                    // Add Button
                    addToQueueButton
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingManualQueue = false
                    }
                }
            }
        }
        .alert("Added to Apple Music Queue", isPresented: $showingSuccessAlert) {
            Button("OK") {
                showingManualQueue = false
            }
        } message: {
            Text("\(numberOfPlays) copies of \(song.title) have been added to your Apple Music queue. Open the Music app to start playback.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Song Card

    private var songCard: some View {
        VStack(alignment: .center, spacing: 12) {
            // Artwork
            if let artworkImage = song.artworkImage {
                Image(uiImage: artworkImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                    }
            }

            // Song Info
            VStack(spacing: 6) {
                Text(song.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Current play count
                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                        .font(.caption)
                    Text("\(song.playCount) plays")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Number Input

    private var numberInputSection: some View {
        VStack(spacing: 16) {
            Text("Number of Plays to Add")
                .font(.headline)

            HStack(spacing: 16) {
                // Decrease button
                Button {
                    if numberOfPlays > 1 {
                        numberOfPlays -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(numberOfPlays > 1 ? .blue : .gray)
                }
                .disabled(numberOfPlays <= 1)

                // Number display
                TextField("Number", value: $numberOfPlays, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .keyboardType(.numberPad)
                    .frame(width: 120)
                    .onChange(of: numberOfPlays) { _, newValue in
                        // Validate range
                        if newValue < 1 {
                            numberOfPlays = 1
                        } else if newValue > 1000 {
                            numberOfPlays = 1000
                        }
                    }

                // Increase button
                Button {
                    if numberOfPlays < 1000 {
                        numberOfPlays += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(numberOfPlays < 1000 ? .blue : .gray)
                }
                .disabled(numberOfPlays >= 1000)
            }

            Text("Enter a number between 1 and 1000")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Amount Buttons

    private var quickAmountButtons: some View {
        VStack(spacing: 12) {
            Text("Quick Add")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach([10, 25, 50, 100], id: \.self) { amount in
                    Button {
                        numberOfPlays = amount
                    } label: {
                        Text("+\(amount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .tint(numberOfPlays == amount ? .blue : .gray)
                }
            }
        }
    }

    // MARK: - Add Button

    private var addToQueueButton: some View {
        Button {
            addToQueue()
        } label: {
            Label("Add to Queue", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    // MARK: - Actions

    private func addToQueue() {
        // Validate
        guard numberOfPlays >= 1 && numberOfPlays <= 1000 else {
            errorMessage = "Please enter a number between 1 and 1000"
            showingErrorAlert = true
            return
        }

        // Add to queue
        do {
            try queueService.addToQueue(song: song, count: numberOfPlays)
            showingSuccessAlert = true
        } catch {
            errorMessage = "Failed to add songs to queue. Please try again."
            showingErrorAlert = true
        }
    }
}
