# Database schema

The MVP uses SwiftData.

## PracticeSession

- `id`: UUID primary identifier
- `startedAt`, `endedAt`: session times
- `cameraVideoFilename`: continuous session video
- `cameraPreRollSeconds`, `cameraPostRollSeconds`: future clip settings
- `r10Model`, `r10Firmware`: device metadata

## ShotRecord

Stores the session key, shot sequence, native R10 shot ID, shot type, app receipt time, R10 impact time, camera elapsed marker, raw club/ball/launch/spin/swing metrics, optional clip filename and notes.

Raw telemetry is persisted deliberately; display conversions such as mph are derived in code so unit preferences do not alter stored data.
