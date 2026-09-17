import AVFoundation
import Foundation

@MainActor
final class CameraRecorder: NSObject, ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var isRecording = false
    @Published private(set) var recordingStartedAt: Date?
    let session = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
    private(set) var videoURL: URL?

    func prepare() async throws {
        guard !isRunning else { return }
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        guard granted else { throw CameraError.permissionDenied }
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { throw CameraError.noCamera }
        session.beginConfiguration(); session.sessionPreset = .high
        defer { session.commitConfiguration() }
        let input = try AVCaptureDeviceInput(device: camera)
        guard session.canAddInput(input), session.canAddOutput(movieOutput) else { throw CameraError.configurationFailed }
        session.addInput(input); session.addOutput(movieOutput)
        if let connection = movieOutput.connection(with: .video), connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
        session.startRunning(); isRunning = true
    }

    func startRecording() throws {
        guard isRunning, !isRecording else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("session-\(UUID().uuidString).mov")
        videoURL = url; recordingStartedAt = .now; isRecording = true
        movieOutput.startRecording(to: url, recordingDelegate: self)
    }

    func stopRecording() async -> URL? {
        guard isRecording else { return videoURL }
        movieOutput.stopRecording(); return videoURL
    }

    func elapsed(at date: Date) -> Double? {
        guard let start = recordingStartedAt else { return nil }
        return max(0, date.timeIntervalSince(start))
    }

    enum CameraError: LocalizedError {
        case permissionDenied, noCamera, configurationFailed
        var errorDescription: String? {
            switch self { case .permissionDenied: return "Camera permission was denied."; case .noCamera: return "No rear camera was found."; case .configurationFailed: return "The camera could not be configured." }
        }
    }
}

extension CameraRecorder: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {}
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        Task { @MainActor [weak self] in self?.isRecording = false; if let error { print("Camera recording finished with error: \(error)") } }
    }
}
