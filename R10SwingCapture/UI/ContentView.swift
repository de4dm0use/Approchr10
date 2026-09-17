import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var app: AppModel
    @Query(sort: \ShotRecord.shotNumber, order: .reverse) private var recentShots: [ShotRecord]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CameraPreview(captureSession: app.camera.session)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    HStack {
                        Label(app.r10Connected ? "R10 connected" : "R10 offline", systemImage: "dot.radiowaves.left.and.right")
                        Spacer()
                        Toggle("Demo R10", isOn: $app.useDemoR10).labelsHidden()
                    }
                    if let latest = app.latestShot { ShotCard(shot: latest) }
                    else { ContentUnavailableView("No shots yet", systemImage: "figure.golf", description: Text("Start a practice session and hit a shot.")) }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent shots").font(.headline)
                        ForEach(recentShots.prefix(12)) { shot in ShotRow(shot: shot) }
                    }
                }.padding()
            }
            .navigationTitle("R10 Swing Capture")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(app.camera.isRecording ? "Stop" : "Start") { Task { if app.camera.isRecording { await app.stopSession() } else { await app.startSession() } } }
                        .buttonStyle(.borderedProminent)
                }
            }
            .task { await app.prepareCamera() }
            .alert("Error", isPresented: Binding(get: { app.errorMessage != nil }, set: { if !$0 { app.errorMessage = nil } })) {
                Button("OK", role: .cancel) { app.errorMessage = nil }
            } message: { Text(app.errorMessage ?? "Unknown error") }
        }
    }
}

private struct ShotCard: View {
    let shot: ShotRecord
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("Shot #\(shot.shotNumber)").font(.title3.weight(.bold)); Spacer(); Text(shot.shotType.capitalized).font(.caption.weight(.semibold)) }
            HStack(spacing: 20) {
                Metric(title: "Ball", value: speedMph(shot.ballSpeedMps))
                Metric(title: "Club", value: speedMph(shot.clubHeadSpeedMps))
                Metric(title: "Launch", value: degrees(shot.launchAngleDeg))
                Metric(title: "Spin", value: rpm(shot.totalSpinRpm))
            }
            Text(String(format: "Video marker %.2fs", shot.cameraElapsedAtReceipt)).font(.caption).foregroundStyle(.secondary)
        }.padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
    private func speedMph(_ mps: Double?) -> String { guard let mps else { return "—" }; return String(format: "%.0f mph", mps * 2.236936) }
    private func degrees(_ value: Double?) -> String { guard let value else { return "—" }; return String(format: "%.1f°", value) }
    private func rpm(_ value: Double?) -> String { guard let value else { return "—" }; return String(format: "%.0f rpm", value) }
}

private struct Metric: View {
    let title: String; let value: String
    var body: some View { VStack(alignment: .leading) { Text(title).font(.caption).foregroundStyle(.secondary); Text(value).font(.subheadline.weight(.semibold)) } }
}

private struct ShotRow: View {
    let shot: ShotRecord
    var body: some View {
        HStack {
            Text("#\(shot.shotNumber)").font(.headline.monospacedDigit()).frame(width: 44, alignment: .leading)
            VStack(alignment: .leading) { Text(shot.shotType.capitalized).font(.subheadline.weight(.medium)); Text(String(format: "Video %.2fs", shot.cameraElapsedAtReceipt)).font(.caption).foregroundStyle(.secondary) }
            Spacer()
            if let speed = shot.ballSpeedMps { Text(String(format: "%.0f mph", speed * 2.236936)).font(.subheadline.monospacedDigit()) }
        }.padding(.vertical, 6)
    }
}
