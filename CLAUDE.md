# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **Unity as a Library (UaaL)** demo for iOS. A native SwiftUI app embeds a Unity runtime as a sub-view rather than Unity owning the app lifecycle.

Two top-level directories:
- `UnityProject/` — Unity 6 (6000.4.6f1) project, built with URP 2D
- `NativeiOSApp/` — Native iOS app (Swift/SwiftUI + Objective-C) that hosts the Unity runtime

## Build Process

**Step 1 — Build Unity for iOS:**
1. Open `UnityProject/` in Unity 6 Editor
2. File > Build Settings > iOS > Build
3. Point the output to `UnityProject/Build/`

This produces `UnityFramework.framework`, which the native app loads at runtime.

**Step 2 — Build & run the iOS app:**
1. Open `NativeiOSApp/NativeiOSApp.xcworkspace` in Xcode
2. Ensure `UnityFramework.framework` is embedded in the app target (from `UnityProject/Build/`)
3. Build and run on device or simulator

There is no `Makefile` or script — both steps are driven by their respective IDEs.

## Architecture

### How Unity is embedded

`UnityLauncher` (`UnityLauncher.h/.m`) is an Objective-C singleton that bridges native iOS and Unity:

1. At launch it dynamically loads `Frameworks/UnityFramework.framework` from the main app bundle using `NSBundle`.
2. It calls `runEmbeddedWithArgc:argv:appLaunchOpts:` to start Unity without UIApplicationMain — Unity runs in embedded mode.
3. `showUnityWindow` / `showUnity` bring the Unity `UIWindow` to the front.
4. The `UnityFrameworkListener` protocol handles `unityDidUnload:` to clear the framework handle if Unity unloads.

The bridging header (`NativeiOSApp-Bridging-Header.h`) imports `UnityLauncher.h` so Swift can call it directly.

### Native UI layer

`ContentView.swift` is a SwiftUI view with a single button:
- First tap: calls `UnityLauncher.shared().launchUnityIfNeeded()` — initialises and shows the Unity window.
- Subsequent taps: calls `UnityLauncher.shared().showUnity()` — brings Unity window back to front.

### Unity build output

`UnityProject/Build/Classes/` contains the Unity-generated Objective-C/C++ glue code (`main.mm`, UI classes, plugin base classes). These are compiled into `UnityFramework.framework` and are not meant to be edited manually — they get overwritten on each Unity build.

### Key constraint

Unity can only be initialised once per process. `UnityLauncher` guards against re-initialisation with the `_ufw` static handle and the `runCount` inside `UnityFramework`. Never call `launchUnityIfNeeded` a second time after Unity is already running; use `showUnity` instead.
