# Architecture

```mermaid
flowchart LR
    R10[Garmin Approach R10] -->|BLE shot events| R10Provider[R10Provider]
    Demo[Demo provider] --> R10Provider
    R10Provider --> Coordinator[SessionCoordinator]
    Camera[AVFoundation Camera] --> Coordinator
    Coordinator --> Store[SwiftData ShotStore]
    Store --> UI[SwiftUI Dashboard]
    Coordinator --> Timeline[Shot timeline markers]
    Timeline --> Video[Session video]
```

The R10 provider is isolated behind a protocol. Camera capture is isolated in `CameraRecorder`. `AppModel` coordinates sessions and persists each shot immediately. The MVP is local-first and works without a server.

Synchronization retains both R10 impact time and phone receipt time, plus the camera elapsed marker. A later calibration flow can estimate BLE/video offset using a visible sync marker.
