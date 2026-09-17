import Foundation

@MainActor
protocol R10Provider: AnyObject {
    var name: String { get }
    var isConnected: Bool { get }
    func start() async
    func stop() async
    func shots() -> AsyncStream<AppShot>
}
