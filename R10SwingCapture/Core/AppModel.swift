import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var useDemoR10 = true
    @Published private(set) var session: PracticeSession?
    @Published private(set) var latestShot: ShotRecord?
    @Published private(set) var shotCount = 0
    @Published private(set) var r10Connected = false
    @Published var errorMessage: String?

    let camera = CameraRecorder()
    let store: ShotStore
    private var r10Provider: R10Provider
    private var shotTask: Task<Void, Never>?

    init() throws {
        store = try ShotStore()
        r10Provider = DemoR10Provider()
    }

    func prepareCamera() async {
        do { try await camera.prepare() } catch { errorMessage = error.localizedDescription }
    }

    func startSession() async {
        guard session == nil else { return }
        do {
            shotCount = 0; latestShot = nil
            try camera.startRecording()
            let newSession = PracticeSession()
            session = newSession
            try store.insert(newSession)
            r10Provider = useDemoR10 ? DemoR10Provider() : R10KitProvider()
            let stream = r10Provider.shots()
            shotTask = Task { [weak self] in
                guard let self else { return }
                for await shot in stream { await self.accept(shot) }
            }
            await r10Provider.start()
            r10Connected = r10Provider.isConnected
        } catch {
            errorMessage = error.localizedDescription
            await stopSession()
        }
    }

    func stopSession() async {
        shotTask?.cancel(); shotTask = nil
        await r10Provider.stop()
        let finishedVideoURL = await camera.stopRecording()
        r10Connected = false
        if let session {
            session.endedAt = .now
            session.cameraVideoFilename = finishedVideoURL?.lastPathComponent
            try? store.save()
        }
        self.session = nil
    }

    private func accept(_ appShot: AppShot) async {
        guard let session else { return }
        let elapsed = camera.elapsed(at: appShot.receivedAt) ?? 0
        let record = ShotRecord(sessionID: session.id, shotNumber: shotCount + 1, r10ShotID: appShot.r10ShotID, shotType: appShot.shotType, capturedAt: appShot.receivedAt, r10ImpactAt: appShot.impactAt, cameraElapsedAtReceipt: elapsed, clubHeadSpeedMps: appShot.clubHeadSpeedMps, ballSpeedMps: appShot.ballSpeedMps, launchAngleDeg: appShot.launchAngleDeg, launchDirectionDeg: appShot.launchDirectionDeg, totalSpinRpm: appShot.totalSpinRpm, spinAxisDeg: appShot.spinAxisDeg, attackAngleDeg: appShot.attackAngleDeg, clubPathDeg: appShot.clubPathDeg, clubFaceDeg: appShot.clubFaceDeg, backswingStartMs: appShot.backswingStartMs, downswingStartMs: appShot.downswingStartMs, impactTimeMs: appShot.impactTimeMs, followThroughEndMs: appShot.followThroughEndMs)
        do { try store.insert(record); shotCount += 1; latestShot = record; r10Connected = r10Provider.isConnected }
        catch { errorMessage = "Could not save shot: \(error.localizedDescription)" }
    }
}
