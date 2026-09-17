import SwiftUI
import SwiftData

@main
struct R10SwingCaptureApp: App {
    @StateObject private var app: AppModel

    init() {
        do {
            _app = StateObject(wrappedValue: try AppModel())
        } catch {
            fatalError("Failed to create app model: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(app)
                .modelContainer(app.store.container)
        }
    }
}
