import Foundation

enum QueueBehavior: String, CaseIterable, Identifiable, RawRepresentable {
    case insertNext = "prepend"
    case replaceQueue = "replace"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .replaceQueue:
            return "Replace Queue"
        case .insertNext:
            return "Insert Next"
        }
    }

    var description: String {
        switch self {
        case .replaceQueue:
            return "Wipes existing queue and starts playing your songs immediately"
        case .insertNext:
            return "Plays your songs next, after the current song finishes"
        }
    }

    var icon: String {
        switch self {
        case .replaceQueue:
            return "arrow.clockwise.circle.fill"
        case .insertNext:
            return "arrow.up.circle.fill"
        }
    }
}
