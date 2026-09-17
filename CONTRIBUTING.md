# Contributing

Start with the MVP boundaries:

1. Keep R10-specific code inside `R10/R10KitProvider.swift`.
2. Keep camera capture inside `Camera/`.
3. Persist raw telemetry before deriving analytics.
4. Do not commit real swing videos or personal practice data.
5. Add reproducible demo-mode tests where possible.

For changes to R10 parsing itself, contribute upstream to R10Kit unless the change is specific to this app's adapter layer.
