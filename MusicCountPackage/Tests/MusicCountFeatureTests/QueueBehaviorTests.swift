import Foundation
import Testing
@testable import MusicCountFeature

/// Tests for QueueBehavior enum.
@Suite("QueueBehavior Tests")
struct QueueBehaviorTests {

    // MARK: - Display Properties

    @Test("Insert Next has correct display name")
    func insertNextDisplayName() {
        #expect(QueueBehavior.insertNext.displayName == "Insert Next")
    }

    @Test("Replace Queue has correct display name")
    func replaceQueueDisplayName() {
        #expect(QueueBehavior.replaceQueue.displayName == "Replace Queue")
    }

    @Test("Insert Next has correct description")
    func insertNextDescription() {
        #expect(QueueBehavior.insertNext.description.contains("next"))
    }

    @Test("Replace Queue has correct description")
    func replaceQueueDescription() {
        #expect(QueueBehavior.replaceQueue.description.contains("Wipes"))
    }

    @Test("All behaviors have icons")
    func allBehaviorsHaveIcons() {
        for behavior in QueueBehavior.allCases {
            #expect(!behavior.icon.isEmpty)
            #expect(behavior.icon.contains("circle"))
        }
    }

    // MARK: - Identifiable

    @Test("ID equals raw value")
    func idEqualsRawValue() {
        for behavior in QueueBehavior.allCases {
            #expect(behavior.id == behavior.rawValue)
        }
    }

    // MARK: - Raw Values

    @Test("Insert Next raw value is prepend")
    func insertNextRawValue() {
        #expect(QueueBehavior.insertNext.rawValue == "prepend")
    }

    @Test("Replace Queue raw value is replace")
    func replaceQueueRawValue() {
        #expect(QueueBehavior.replaceQueue.rawValue == "replace")
    }

    @Test("Can initialize from raw value")
    func initFromRawValue() {
        let prepend = QueueBehavior(rawValue: "prepend")
        let replace = QueueBehavior(rawValue: "replace")

        #expect(prepend == .insertNext)
        #expect(replace == .replaceQueue)
    }

    @Test("Invalid raw value returns nil")
    func invalidRawValue() {
        let invalid = QueueBehavior(rawValue: "invalid")
        #expect(invalid == nil)
    }

    // MARK: - CaseIterable

    @Test("All cases contains both behaviors")
    func allCasesComplete() {
        let allCases = QueueBehavior.allCases
        #expect(allCases.count == 2)
        #expect(allCases.contains(.insertNext))
        #expect(allCases.contains(.replaceQueue))
    }
}
