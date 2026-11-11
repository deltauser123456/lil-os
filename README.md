# Lil-OS

Lil-OS is a desktop-style operating-system experience built as a native SwiftUI iPhone app. It does not replace iOS or install as a separate system firmware.

## Features
- Polished lock screen with live clock, date, swipe-up gesture, and unlock button
- Desktop wallpaper and status/menu bar with a lock control
- App launcher and dock
- Desktop shortcuts
- Window-style app panels with close controls and draggable title bars
- Files, Notepad, Calculator, Settings, and About apps
- Editable notes, working basic calculator, and selectable wallpapers

## Build
This repository uses [XcodeGen](https://github.com/yonaskolb/XcodeGen).

1. Install Xcode and XcodeGen on a Mac.
2. Clone this repository.
3. Run `xcodegen generate`.
4. Open `LilOS.xcodeproj` in Xcode.
5. Select an iPhone simulator or your connected iPhone and build.

To install on a physical iPhone or export an IPA, select your Apple development Team in Xcode under Signing & Capabilities. A signed IPA requires valid Apple signing credentials and provisioning.

## GitHub Actions
The workflow in `.github/workflows/ios-build.yml` generates the Xcode project and builds the iOS Simulator target on every push.
