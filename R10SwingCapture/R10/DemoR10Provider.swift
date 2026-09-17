import Foundation

@MainActor
final class DemoR10Provider: R10Provider {
    let name = "Demo R10"
    private(set) var isConnected = false
    private var continuation: AsyncStream<AppShot>.Continuation?
    private var task: Task<Void, Never>?
    private var shotID: Int64 = 1000

    func shots() -> AsyncStream<AppShot> {
        AsyncStream { continuation in self.continuation = continuation }
    }

    func start() async {
        isConnected = true
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { break }
                shotID += 1
                let receipt = Date()
                let speed = 42.0 + Double(shotID % 8)
                continuation?.yield(AppShot(r10ShotID: shotID, shotType: "normal", impactAt: receipt, receivedAt: receipt, clubHeadSpeedMps: speed, ballSpeedMps: speed * 1.46, launchAngleDeg: 12.5, launchDirectionDeg: 1.4, totalSpinRpm: 2400, spinAxisDeg: -4.2, attackAngleDeg: -1.8, clubPathDeg: 2.1, clubFaceDeg: 1.0, backswingStartMs: 1000, downswingStartMs: 2050, impactTimeMs: 2430, followThroughEndMs: 2900))
            }
        }
    }

    func stop() async {
        task?.cancel(); task = nil
        continuation?.finish(); continuation = nil
        isConnected = false
    }
}
