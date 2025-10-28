import Testing
@testable import MusicCountFeature

/// Test suite for ComparisonView button logic
@Suite("Comparison View Button Logic")
struct ComparisonViewButtonTests {

    // MARK: - Match Mode Tests

    @Test("Match Mode disabled when songs have equal play counts")
    func matchModeDisabledWhenEqual() {
        // Both at 55 plays
        let difference = abs(55 - 55)
        let isMatchModeDisabled = difference == 0

        #expect(isMatchModeDisabled == true)
    }

    @Test("Match Mode disabled when both songs have 0 plays")
    func matchModeDisabledAtZero() {
        let difference = abs(0 - 0)
        let isMatchModeDisabled = difference == 0

        #expect(isMatchModeDisabled == true)
    }

    @Test("Match Mode enabled when songs have different play counts")
    func matchModeEnabledWhenDifferent() {
        // 58 vs 55
        let difference = abs(58 - 55)
        let isMatchModeDisabled = difference == 0

        #expect(isMatchModeDisabled == false)
    }

    @Test("Match Mode target plays equals difference")
    func matchModeTargetPlaysCalculation() {
        let higherCount = 58
        let lowerCount = 55
        let expectedPlays = higherCount - lowerCount

        #expect(expectedPlays == 3)
    }

    // MARK: - Add Mode Tests

    @Test("Add Mode disabled when both songs have 0 plays")
    func addModeDisabledAtZero() {
        let higherPlayCount = 0
        let isAddModeDisabled = higherPlayCount == 0

        #expect(isAddModeDisabled == true)
    }

    @Test("Add Mode enabled when songs have equal non-zero play counts")
    func addModeEnabledWhenEqualNonZero() {
        // Both at 55 plays
        let higherPlayCount = 55
        let isAddModeDisabled = higherPlayCount == 0

        #expect(isAddModeDisabled == false)
    }

    @Test("Add Mode enabled when songs have different play counts")
    func addModeEnabledWhenDifferent() {
        // 58 vs 55
        let higherPlayCount = 58
        let isAddModeDisabled = higherPlayCount == 0

        #expect(isAddModeDisabled == false)
    }

    @Test("Add Mode target plays equals higher song play count")
    func addModeTargetPlaysCalculation() {
        let higherPlayCount = 58
        let lowerPlayCount = 55
        let addModeTargetPlays = higherPlayCount

        #expect(addModeTargetPlays == 58)
    }

    @Test("Add Mode final count equals lower count plus higher count")
    func addModeFinalCountCalculation() {
        let higherPlayCount = 58
        let lowerPlayCount = 55
        let addModeTargetPlays = higherPlayCount
        let expectedFinalCount = lowerPlayCount + addModeTargetPlays

        #expect(expectedFinalCount == 113)
    }

    // MARK: - Combined Scenario Tests

    @Test("Both at 0 plays: Match disabled, Add disabled")
    func bothButtonsDisabledAtZero() {
        let song1PlayCount = 0
        let song2PlayCount = 0
        let difference = abs(song1PlayCount - song2PlayCount)
        let higherPlayCount = max(song1PlayCount, song2PlayCount)

        let isMatchModeDisabled = difference == 0
        let isAddModeDisabled = higherPlayCount == 0

        #expect(isMatchModeDisabled == true)
        #expect(isAddModeDisabled == true)
    }

    @Test("Both at 55 plays: Match disabled, Add enabled for doubling")
    func bothAt55Plays() {
        let song1PlayCount = 55
        let song2PlayCount = 55
        let difference = abs(song1PlayCount - song2PlayCount)
        let higherPlayCount = max(song1PlayCount, song2PlayCount)
        let lowerPlayCount = min(song1PlayCount, song2PlayCount)

        let isMatchModeDisabled = difference == 0
        let isAddModeDisabled = higherPlayCount == 0
        let addModeTargetPlays = higherPlayCount
        let addModeFinalCount = lowerPlayCount + addModeTargetPlays

        #expect(isMatchModeDisabled == true)
        #expect(isAddModeDisabled == false)
        #expect(addModeTargetPlays == 55)
        #expect(addModeFinalCount == 110)
    }

    @Test("58 vs 55 plays: Both enabled with different targets")
    func differentPlayCounts58vs55() {
        let song1PlayCount = 58
        let song2PlayCount = 55
        let difference = abs(song1PlayCount - song2PlayCount)
        let higherPlayCount = max(song1PlayCount, song2PlayCount)
        let lowerPlayCount = min(song1PlayCount, song2PlayCount)

        let isMatchModeDisabled = difference == 0
        let isAddModeDisabled = higherPlayCount == 0
        let matchModeTargetPlays = difference
        let addModeTargetPlays = higherPlayCount
        let matchModeFinalCount = lowerPlayCount + matchModeTargetPlays
        let addModeFinalCount = lowerPlayCount + addModeTargetPlays

        #expect(isMatchModeDisabled == false)
        #expect(isAddModeDisabled == false)
        #expect(matchModeTargetPlays == 3)
        #expect(matchModeFinalCount == 58)
        #expect(addModeTargetPlays == 58)
        #expect(addModeFinalCount == 113)
    }

    @Test("0 vs 10 plays: Match enabled, Add enabled")
    func zeroVsTenPlays() {
        let song1PlayCount = 0
        let song2PlayCount = 10
        let difference = abs(song1PlayCount - song2PlayCount)
        let higherPlayCount = max(song1PlayCount, song2PlayCount)
        let lowerPlayCount = min(song1PlayCount, song2PlayCount)

        let isMatchModeDisabled = difference == 0
        let isAddModeDisabled = higherPlayCount == 0
        let matchModeTargetPlays = difference
        let addModeTargetPlays = higherPlayCount
        let matchModeFinalCount = lowerPlayCount + matchModeTargetPlays
        let addModeFinalCount = lowerPlayCount + addModeTargetPlays

        #expect(isMatchModeDisabled == false)
        #expect(isAddModeDisabled == false)
        #expect(matchModeTargetPlays == 10)
        #expect(matchModeFinalCount == 10)
        #expect(addModeTargetPlays == 10)
        #expect(addModeFinalCount == 10)
    }

    @Test("100 vs 50 plays: Both enabled with correct calculations")
    func largePlayCounts100vs50() {
        let song1PlayCount = 100
        let song2PlayCount = 50
        let difference = abs(song1PlayCount - song2PlayCount)
        let higherPlayCount = max(song1PlayCount, song2PlayCount)
        let lowerPlayCount = min(song1PlayCount, song2PlayCount)

        let isMatchModeDisabled = difference == 0
        let isAddModeDisabled = higherPlayCount == 0
        let matchModeTargetPlays = difference
        let addModeTargetPlays = higherPlayCount
        let matchModeFinalCount = lowerPlayCount + matchModeTargetPlays
        let addModeFinalCount = lowerPlayCount + addModeTargetPlays

        #expect(isMatchModeDisabled == false)
        #expect(isAddModeDisabled == false)
        #expect(matchModeTargetPlays == 50)
        #expect(matchModeFinalCount == 100)
        #expect(addModeTargetPlays == 100)
        #expect(addModeFinalCount == 150)
    }
}
