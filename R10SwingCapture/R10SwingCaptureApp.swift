import SwiftUI
import SwiftData

@main
struct R10SwingCaptureApp: App {
    @StateObject private var app: AppModel

    init() {
        _app = StateObject(wrappedValue: AppModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(app)
                .modelContainer(app.store.container)
        }
    }
}
