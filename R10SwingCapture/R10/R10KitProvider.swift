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

        let shotStream: AsyncStream<R10ShotEvent> = device.shotEvents
        let shotContinuation: AsyncStream<AppShot>.Continuation? = continuation

        shotTask = Task<Void, Never> { [shotStream, shotContinuation] in
            await Self.consumeShots(stream: shotStream, continuation: shotContinuation)
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

    private nonisolated static func consumeShots(
        stream: AsyncStream<R10ShotEvent>,
        continuation: AsyncStream<AppShot>.Continuation?
    ) async {
        for await shot in stream {
            let club = shot.metrics.clubMetrics
            let ball = shot.metrics.ballMetrics
            let swing = shot.metrics.swingMetrics

            // R10Kit uses Float and UInt32 for these values; AppShot stores
            // Double and Int64. Convert each value explicitly.
            let appShot = AppShot(
                r10ShotID: shot.metrics.shotId.map { Int64($0) },
                shotType: String(describing: shot.metrics.shotType),
                impactAt: shot.wallClockImpactAt,
                receivedAt: Date(),
                clubHeadSpeedMps: club?.clubHeadSpeed.map { Double($0) },
                ballSpeedMps: ball?.ballSpeed.map { Double($0) },
                launchAngleDeg: ball?.launchAngle.map { Double($0) },
                launchDirectionDeg: ball?.launchDirection.map { Double($0) },
                totalSpinRpm: ball?.totalSpin.map { Double($0) },
                spinAxisDeg: ball?.spinAxis.map { Double($0) },
                attackAngleDeg: club?.attackAngle.map { Double($0) },
                clubPathDeg: club?.clubAnglePath.map { Double($0) },
                clubFaceDeg: club?.clubAngleFace.map { Double($0) },
                backswingStartMs: swing?.backSwingStartTime.map { Int64($0) },
                downswingStartMs: swing?.downSwingStartTime.map { Int64($0) },
                impactTimeMs: swing?.impactTime.map { Int64($0) },
                followThroughEndMs: swing?.followThroughEndTime.map { Int64($0) }
            )

            continuation?.yield(appShot)
        }
    }
}
