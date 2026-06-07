# Unity as a Library (UaaL) iOS Demo

A demo project showing how to embed a Unity runtime inside a native SwiftUI iOS app using **Unity as a Library (UaaL)**. Unity runs as a sub-view rather than owning the app lifecycle, and the two sides communicate through a bidirectional JSON message bus.

## What this demonstrates

- Embedding `UnityFramework.framework` in a native SwiftUI app
- Launching and showing/hiding the Unity window on demand
- Sending messages from Unity to native (e.g. hide Unity, update native UI text)
- Sending large JSON payloads from native to Unity using chunked Base64 transfer

## Project structure

```
.
├── NativeiOSApp/          # Native iOS app (Swift/SwiftUI + Objective-C)
│   └── NativeiOSApp/
│       ├── ContentView.swift          # SwiftUI entry point, Launch/Show Unity button
│       ├── UnityLauncher.h/.m         # ObjC singleton that loads and drives UnityFramework
│       ├── JsonLoader.swift           # Loads bundled JSON files, encodes chunks
│       └── SampleData/                # json1_1MB.json, json2_3MB.json
│
└── UnityProject/          # Unity 6 project (URP 2D)
    └── Assets/
        ├── Scenes/
        │   ├── StartScene             # Initial Unity scene with a "Go to Main" button
        │   └── MainScene              # Main scene with model loading and JSON request buttons
        └── Scripts/
            ├── NativeBridge.cs        # Singleton — calls native via DllImport, receives callbacks
            ├── NativeMessage.cs       # Serialisable message struct (type + payload)
            ├── NativeMessageDispatcher.cs  # Reassembles chunked messages, fires event when complete
            └── UI/
                ├── StartSceneCanvasController.cs
                └── MainSceneCanvasController.cs
```

## Architecture

### Embedding Unity

`UnityLauncher` (Objective-C singleton) dynamically loads `UnityFramework.framework` from the app bundle at runtime via `NSBundle`. It calls `runEmbeddedWithArgc:argv:appLaunchOpts:` to start Unity without `UIApplicationMain`, then uses `showUnityWindow` / `pause:` to bring the Unity `UIWindow` to the front or background.

> Unity can only be initialised once per process. `UnityLauncher` guards against re-initialisation. Use `showUnity` to bring it back after the first launch.

### Message bus (Unity → Native)

Unity calls `SendMessageToNative(string json)` (a C `DllImport` into the native side). The native app posts an `NSNotificationCenter` notification (`UnityMessageNotification`) which `UnityLauncher` handles. Supported message types:

| `type`        | Effect                                      |
|---------------|---------------------------------------------|
| `UpdateText`  | Updates a text label in the native UI       |
| `HideUnity`   | Pauses Unity and brings native window forward |
| `KillUnity`   | Unloads the Unity application               |
| `RequestJson` | Asks native to send a JSON file to Unity    |

### Message bus (Native → Unity)

Native calls `sendMessageToGOWithName:"NativeBridge" functionName:"OnMessageReceived"` on the Unity framework. `NativeBridge.cs` receives the call and fires an `onMessageReceived` event.

### Chunked Base64 JSON transfer

Because `sendMessageToGOWithName` has a practical size limit, large payloads are split into 256-byte chunks on the native side, each Base64-encoded and wrapped in a `MessageJson` envelope `{ id, chunkIndex, totalChunks, data }`. `NativeMessageDispatcher.cs` collects chunks keyed by `id`, reassembles them in order, Base64-decodes the bytes, and emits a single `onMessageDispatched(id, fullJson)` event when all chunks arrive.

## Build instructions

### 1. Build Unity for iOS

1. Open `UnityProject/` in **Unity 6 (6000.4.6f1)**.
2. **File > Build Settings > iOS > Build** — output to `UnityProject/Build/`.

This produces `UnityFramework.framework`.

### 2. Build & run the native app

1. Open `NativeiOSApp/NativeiOSApp.xcworkspace` in **Xcode**.
2. Confirm `UnityFramework.framework` is embedded in the app target (from `UnityProject/Build/`).
3. Build and run on a **physical device** (Unity is not available on the simulator — the app compiles but Unity features are stubbed out).

There is no Makefile or script — both steps are driven by their respective IDEs.

## TODO

- [ ] **Localization** — support multiple languages across both the native app and Unity scenes
- [ ] **Multi-language font support** — load locale-appropriate fonts (e.g. CJK, Arabic, Latin) that cover all target scripts
- [ ] **Shared font pipeline** — bundle fonts once in the native app and expose them to Unity at runtime, so both sides render text with the same typeface without duplicating assets

## Credits

| Asset | Author | Source |
|-------|--------|--------|
| Hover Bike - The Rocket | — | [Sketchfab](https://sketchfab.com/3d-models/hover-bike-the-rocket-8b2e5bfca78e41c791b4e5b5e8c04512) |

## Requirements

- Unity 6 (6000.4.6f1) with iOS Build Support module
- Xcode 16+
- iOS device (simulator shows native UI only)
