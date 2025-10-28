import Foundation

enum QueueBehavior: String, CaseIterable, Identifiable, RawRepresentable {
    case insertNext = "prepend"
    case appendToEnd = "append"
    case replaceQueue = "replace"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .replaceQueue:
            return "Replace Queue"
        case .appendToEnd:
            return "Append to End"
        case .insertNext:
            return "Insert Next"
        }
    }

    var description: String {
        switch self {
        case .replaceQueue:
            return "Wipes existing queue and starts playing your songs immediately"
        case .appendToEnd:
            return "Adds songs to the end of your current queue"
        case .insertNext:
            return "Plays your songs next, after the current song finishes"
        }
    }

    var icon: String {
        switch self {
        case .replaceQueue:
            return "arrow.clockwise.circle.fill"
        case .appendToEnd:
            return "text.append"
        case .insertNext:
            return "arrow.up.circle.fill"
        }
    }
}
