import Foundation
import R10Kit

/// Adapter around the unofficial reverse-engineered R10Kit package.
/// Keep the rest of the app independent of R10Kit's concrete types.
@MainActor
final class R10KitProvider: R10Provider {
    let name = "Garmin Approach R10"
    private(set) var isConnected = false
    private let connection = R10Connection()
    private lazy var device = R10Device(connection: connection)
    private var phaseTask: Task<Void, Never>?
    private var shotTask: Task<Void, Never>?
    private var continuation: AsyncStream<AppShot>.Continuation?

    func shots() -> AsyncStream<AppShot> {
        AsyncStream<AppShot> { continuation in
            self.continuation = continuation
        }
    }

    func start() async {
        phaseTask?.cancel()
        shotTask?.cancel()

        phaseTask = Task<Void, Never> { [weak self] in
            guard let self else { return }
            for await phase in self.connection.phases {
                await self.device.notifyPhaseChange(phase)
                self.isConnected = true
            }
        }

        // R10ShotEvent and AppShot are Sendable. The SDK exposes
        // shotEvents as a nonisolated AsyncStream, so consume it in a
        // detached task. This avoids Swift 5/Xcode 16's ambiguous Task
        // initializer when an actor-isolated R10Device is captured.
        let shotStream: AsyncStream<R10ShotEvent> = device.shotEvents
        let shotContinuation: AsyncStream<AppShot>.Continuation? = continuation

        shotTask = Task.detached(priority: nil) {
            for await shot in shotStream {
                let club = shot.metrics.clubMetrics
                let ball = shot.metrics.ballMetrics
                let swing = shot.metrics.swingMetrics
                let received = Date()

                shotContinuation?.yield(AppShot(
                    r10ShotID: Int64(shot.metrics.shotId),
                    shotType: String(describing: shot.metrics.shotType),
                    impactAt: shot.wallClockImpactAt,
                    receivedAt: received,
                    clubHeadSpeedMps: club?.clubHeadSpeed,
                    ballSpeedMps: ball?.ballSpeed,
                    launchAngleDeg: ball?.launchAngle,
                    launchDirectionDeg: ball?.launchDirection,
                    totalSpinRpm: ball?.totalSpin,
                    spinAxisDeg: ball?.spinAxis,
                    attackAngleDeg: club?.attackAngle,
                    clubPathDeg: club?.clubAnglePath,
                    clubFaceDeg: club?.clubAngleFace,
                    backswingStartMs: swing?.backSwingStartTime,
                    downswingStartMs: swing?.downSwingStartTime,
                    impactTimeMs: swing?.impactTime,
                    followThroughEndMs: swing?.followThroughEndTime
                ))
            }
        }

        await device.start()
        await connection.start()
    }

    func stop() async {
        phaseTask?.cancel()
        shotTask?.cancel()
        phaseTask = nil
        shotTask = nil
        continuation?.finish()
        continuation = nil
        isConnected = false
        await device.stop()
    }
}
