import Testing
@testable import R10SwingCapture

struct R10SwingCaptureTests {
    @Test func appShotStoresTiming() {
        let now = Date(timeIntervalSince1970: 1_000)
        let shot = AppShot(r10ShotID: 12, shotType: "normal", impactAt: now, receivedAt: now.addingTimeInterval(0.15), clubHeadSpeedMps: 45, ballSpeedMps: 67, launchAngleDeg: 13, launchDirectionDeg: 2, totalSpinRpm: 2500, spinAxisDeg: 0, attackAngleDeg: -2, clubPathDeg: 1, clubFaceDeg: 2, backswingStartMs: 100, downswingStartMs: 200, impactTimeMs: 300, followThroughEndMs: 500)
        #expect(shot.r10ShotID == 12)
        #expect(shot.receivedAt.timeIntervalSince(shot.impactAt!) == 0.15)
    }
}
