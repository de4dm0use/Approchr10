import Foundation
import SwiftData

@Model
final class PracticeSession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var cameraVideoFilename: String?
    var cameraPreRollSeconds: Double
    var cameraPostRollSeconds: Double
    var r10Model: String?
    var r10Firmware: String?

    init(startedAt: Date = .now, cameraPreRollSeconds: Double = 2.0, cameraPostRollSeconds: Double = 2.0) {
        self.id = UUID()
        self.startedAt = startedAt
        self.cameraPreRollSeconds = cameraPreRollSeconds
        self.cameraPostRollSeconds = cameraPostRollSeconds
    }
}
