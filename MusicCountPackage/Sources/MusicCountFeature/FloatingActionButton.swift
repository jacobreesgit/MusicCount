import SwiftUI

struct FloatingActionButton: View {
    let selectedCount: Int
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Main button capsule with icon and text
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.headline)

                    Text("Compare Songs")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(isEnabled ? Color.blue.gradient : Color.secondary.opacity(0.3).gradient)
                )
                .shadow(color: Color.primary.opacity(0.15), radius: 8, x: 0, y: 4)

                // Badge showing selection count
                if selectedCount > 0 {
                    ZStack {
                        Circle()
                            .fill(.red.gradient)
                            .frame(width: 24, height: 24)

                        Text("\(selectedCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .offset(x: 8, y: -4)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .disabled(!isEnabled)
        .buttonStyle(ScaleButtonStyle())
        .padding(.bottom, 16)
        .accessibilityLabel("Compare songs")
        .accessibilityHint("\(selectedCount) of 2 songs selected")
        .accessibilityAddTraits(isEnabled ? [] : .isButton)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedCount)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// Custom button style for scale animation on press
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
