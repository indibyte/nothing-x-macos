# Nothing X for macOS (Unofficial)

An unofficial macOS companion app for Nothing and CMF earbuds. Inspired by the Nothing X iOS app, built with SwiftUI and Core Bluetooth.

> This is a fork of [marlon-yepes/cmf-macos](https://github.com/marlon-yepes/cmf-macos) that adds a build without Xcode and fixes for the CMF Buds 2. See [Changes in this fork](#changes-in-this-fork).

## Supported Devices

**Nothing**
- Ear (1), Ear (2), Ear (2024), Ear (3)
- Ear (a), Ear (stick), Ear (open)
- Headphone (1)

**CMF by Nothing**
- Buds 2, Buds 2 Plus, Buds 2a

## Features

- **Noise Control** — ANC, Transparency, Off with customizable cycle modes
- **Equalizer** — Preset profiles (Balanced, More Bass, More Treble, Voice) and Custom EQ with Bass/Mid/Treble sliders
- **EQ Presets** — Save, load, and manage custom equalizer configurations
- **Enhanced Bass** — Adjustable bass boost (device-dependent)
- **Gesture Controls** — Fully customizable Triple Tap, Double Tap, Tap & Hold, Double Tap & Hold actions per earbud
- **Find My Buds** — Ring left, right, or both earbuds
- **Ear Tip Fit Test** — Measure ear tip seal quality
- **Battery Display** — Real-time L/R/Case levels in the menu bar with configurable display mode (L·R, AVG, MIN)
- **Low Latency Mode** — Toggle for reduced audio latency
- **In-Ear Detection** — Auto-pause when earbuds are removed
- **Case LED Customization** — RGB color control for case LEDs (Ear (1) only)
- **Device Info** — Name, MAC address, serial number, firmware version

> Feature availability varies by device model.

## Screenshots

<table>
  <tr>
    <td><img src="assets/NothingX.png" alt="Main View"></td>
    <td><img src="assets/Equaliser.png" alt="Equaliser"></td>
  </tr>
  <tr>
    <td><img src="assets/Controls.png" alt="Controls"></td>
    <td><img src="assets/EarTipTest.png" alt="Ear Tip Fit Test"></td>
  </tr>
  <tr>
    <td><img src="assets/Settings.png" alt="Settings"></td>
    <td><img src="assets/FindMyBuds.png" alt="Find My Buds"></td>
  </tr>
</table>

## Requirements

- macOS 13.0+
- Xcode 14.0+
- Bluetooth-enabled Mac

## Building

No external dependencies — uses only native Apple frameworks (SwiftUI, Combine, Core Bluetooth).

### Without Xcode (Command Line Tools only)

```sh
xcode-select --install          # if the Command Line Tools aren't installed yet
git clone https://github.com/indibyte/nothing-x-macos
cd nothing-x-macos
scripts/build-app.sh --install  # builds, copies to /Applications and launches
```

Drop `--install` to only build `build/Nothing X.app`. The app is ad-hoc signed for local use; on first launch macOS asks for Bluetooth permission. Since there's no asset catalog compiler without Xcode, the menu bar uses the system `earbuds` symbol instead of the custom ear icon.

### With Xcode

1. Open `Nothing X MacOS.xcodeproj` in Xcode
2. Build and run (Cmd+R)

## Changes in this fork

- **Builds without Xcode** — a root `Package.swift` plus `scripts/build-app.sh` produce a signed `.app` using only the Command Line Tools.
- **Correct RFCOMM channel** — the control channel was hard-coded to 15, but it differs per model (CMF Buds 2 uses 16). The app now looks up the `NTAPP` service via SDP, falling back to 15. Before this, CMF Buds 2 showed as connected but every command timed out.
- **Battery levels** — `0xE002` packets were decoded as battery reports, but on CMF Buds 2 they carry small per-bud status values, which overwrote the real levels (e.g. 4% instead of 100%). Battery now comes only from the real battery reports.
- **Larger window** — the UI is scaled 1.5× (`uiScale` in `Nothing_X_MacOSApp.swift`).

## Acknowledgements

- [Ear (web)](https://earweb.bttl.xyz) — Bluetooth communication protocol reference
- [Arunavo Ray](https://github.com/arunavo4/nothing-x-macos) — Original UI and project foundation

## Disclaimer

This application is not associated with, sponsored by, or endorsed by Nothing Technology. Text, graphics, logos, imagery, and audio-visual resources within this application are the property of Nothing Technology Limited (80 Cheapside, London EC2V 6EE) and are protected by copyright, trademark, and other intellectual property laws. Use of these resources requires explicit written consent from Nothing Technology. All rights reserved by Nothing Technology.
