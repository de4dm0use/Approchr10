# R10 Swing Capture

An iPhone-first open-source golf practice app that combines **Garmin Approach R10 shot telemetry** with **phone camera video**.

## What the MVP does

- Connects directly to a Garmin Approach R10 over Bluetooth LE using the unofficial, reverse-engineered `R10Kit` Swift package.
- Starts an on-phone camera recording for the practice session.
- Records each incoming R10 shot as a local `ShotRecord`.
- Stores both the R10 impact timestamp and the app-side camera elapsed time when the shot arrived.
- Lets you browse shots and see the telemetry associated with each video timestamp.
- Includes a Demo R10 provider so the UI can be developed without an R10 connected.

> **Important:** R10Kit is unofficial and reverse-engineered. This project does not ship Garmin code. See `docs/r10-integration.md` and the upstream project for the protocol/licensing details.

## Tech stack

- **Swift 5.9+ / SwiftUI**
- **iOS 17+**
- **SwiftData** for local-first persistence
- **AVFoundation** for camera capture
- **R10Kit** for direct R10 BLE telemetry
- **Swift Concurrency / AsyncStream** for event flow
- Optional future: Vision / Core ML for swing pose and club analysis

## Repository layout

```text
R10SwingCapture/
├── .github/workflows/ios.yml
├── docs/
│   ├── architecture.md
│   ├── database-schema.md
│   ├── r10-integration.md
│   └── roadmap.md
├── R10SwingCapture.xcodeproj/
├── R10SwingCapture/
│   ├── Camera/
│   ├── Core/
│   ├── Models/
│   ├── R10/
│   ├── Resources/
│   └── UI/
└── R10SwingCaptureTests/
```

## Getting started

1. Open `R10SwingCapture.xcodeproj` in Xcode on a Mac.
2. Set your development Team under **Signing & Capabilities**.
3. Build to a **physical iPhone**. The R10 BLE path cannot be tested in the iOS Simulator.
4. Grant camera and Bluetooth permissions.
5. In the app, leave **Demo R10** enabled for a UI-only test, or disable it to use the real R10.
6. Put the R10 into its normal pairing/discovery state and start a practice session.

### R10Kit dependency

The project depends on the public repository:

`https://github.com/OSSGolf/unofficial-r10-ios-sdk`

The upstream project documents direct BLE connection and exposes per-shot metrics including ball speed, launch angle/direction, spin, club speed, attack angle, face/path and swing timing. It currently documents iOS 17+ support and requires a physical device for BLE testing.

## Camera/shot synchronization model

The MVP records a continuous session video rather than creating one video file per shot. Every shot gets:

- `r10ImpactAt`: R10's wall-clock impact date when supplied by R10Kit
- `receivedAt`: when the iPhone received the event
- `cameraElapsedAtReceipt`: seconds from the start of the camera recording to event receipt
- `cameraPreRollSeconds` / `cameraPostRollSeconds`: future clip-export settings

This is deliberately redundant. It lets the project improve synchronization later without throwing away raw timing evidence.

The next phase can use the stored event markers to cut individual clips with `AVAssetExportSession`.

## Disclaimer

Garmin and Approach R10 are trademarks of Garmin Ltd. This is an independent open-source project and is not affiliated with Garmin. The R10 transport layer is based on reverse-engineered work from the open-source community.

## License

MIT for this project's original code. Third-party dependencies retain their own licenses.
