# R10 integration

This project uses `R10Kit` as an adapter rather than implementing the proprietary BLE protocol itself.

Upstream references:

- https://github.com/OSSGolf/unofficial-r10-ios-sdk
- https://github.com/mholow/gsp-r10-adapter

Only `R10KitProvider.swift` should know about SDK types. The app requires Bluetooth and camera usage descriptions in `Info.plist`.

The live BLE path must be validated on a physical iPhone. R10Kit is unofficial and reverse-engineered, so upstream API changes may require adapter updates.
