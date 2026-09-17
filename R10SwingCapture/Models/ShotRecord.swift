import Foundation
import SwiftData

@Model
final class ShotRecord {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var shotNumber: Int
    var r10ShotID: Int64?
    var shotType: String
    var capturedAt: Date
    var r10ImpactAt: Date?
    var cameraElapsedAtReceipt: Double

    var clubHeadSpeedMps: Double?
    var ballSpeedMps: Double?
    var launchAngleDeg: Double?
    var launchDirectionDeg: Double?
    var totalSpinRpm: Double?
    var spinAxisDeg: Double?
    var attackAngleDeg: Double?
    var clubPathDeg: Double?
    var clubFaceDeg: Double?

    var backswingStartMs: Int64?
    var downswingStartMs: Int64?
    var impactTimeMs: Int64?
    var followThroughEndMs: Int64?

    var videoClipFilename: String?
    var notes: String?

    init(sessionID: UUID, shotNumber: Int, r10ShotID: Int64? = nil, shotType: String = "unknown", capturedAt: Date = .now, r10ImpactAt: Date? = nil, cameraElapsedAtReceipt: Double = 0, clubHeadSpeedMps: Double? = nil, ballSpeedMps: Double? = nil, launchAngleDeg: Double? = nil, launchDirectionDeg: Double? = nil, totalSpinRpm: Double? = nil, spinAxisDeg: Double? = nil, attackAngleDeg: Double? = nil, clubPathDeg: Double? = nil, clubFaceDeg: Double? = nil, backswingStartMs: Int64? = nil, downswingStartMs: Int64? = nil, impactTimeMs: Int64? = nil, followThroughEndMs: Int64? = nil, videoClipFilename: String? = nil, notes: String? = nil) {
        self.id = UUID(); self.sessionID = sessionID; self.shotNumber = shotNumber; self.r10ShotID = r10ShotID; self.shotType = shotType; self.capturedAt = capturedAt; self.r10ImpactAt = r10ImpactAt; self.cameraElapsedAtReceipt = cameraElapsedAtReceipt
        self.clubHeadSpeedMps = clubHeadSpeedMps; self.ballSpeedMps = ballSpeedMps; self.launchAngleDeg = launchAngleDeg; self.launchDirectionDeg = launchDirectionDeg; self.totalSpinRpm = totalSpinRpm; self.spinAxisDeg = spinAxisDeg; self.attackAngleDeg = attackAngleDeg; self.clubPathDeg = clubPathDeg; self.clubFaceDeg = clubFaceDeg
        self.backswingStartMs = backswingStartMs; self.downswingStartMs = downswingStartMs; self.impactTimeMs = impactTimeMs; self.followThroughEndMs = followThroughEndMs; self.videoClipFilename = videoClipFilename; self.notes = notes
    }
}

struct AppShot: Sendable {
    let r10ShotID: Int64?
    let shotType: String
    let impactAt: Date?
    let receivedAt: Date
    let clubHeadSpeedMps: Double?
    let ballSpeedMps: Double?
    let launchAngleDeg: Double?
    let launchDirectionDeg: Double?
    let totalSpinRpm: Double?
    let spinAxisDeg: Double?
    let attackAngleDeg: Double?
    let clubPathDeg: Double?
    let clubFaceDeg: Double?
    let backswingStartMs: Int64?
    let downswingStartMs: Int64?
    let impactTimeMs: Int64?
    let followThroughEndMs: Int64?
}
