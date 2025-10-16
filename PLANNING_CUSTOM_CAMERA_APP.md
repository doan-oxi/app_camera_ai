# Custom Flutter Camera App — Detailed Plan (Clean Architecture)

Date: 2025-10-16
Owner: Senior Flutter/Kotlin/Swift Engineer
Scope: Plan only. No code changes yet.

## 1) Objectives
- Build a custom Flutter camera app using existing Veepai SDKs in this repo
- Scaffold with `flutter create`, organize per strict Clean Architecture
- Integrate Veepai P2P/video/CGI/AI features (Android/iOS)
- Prioritize performance (RxDart, Isolates, multi-thread processing)
- Maintainability (SOLID, KISS, testable, small files)

## 2) Constraints & Principles
- Clean Architecture: Presentation → Domain ← Data ← Infrastructure
- Domain = pure Dart only (no Flutter/SDK/io)
- Naming: meaningful, no `v1`, `enhanced`, `manager`, `handler`, `util`
- Files < 300 LOC, functions < 50 LOC
- State mgmt via Bloc/Cubit; DI via GetIt; RxDart for streams
- Avoid over-engineering; prefer simple, explicit code

## 3) Existing Assets in Repo
- Flutter SDK plugin demo: `flutter-sdk-demo/` (Dart + Android/iOS glue)
- Android AARs: `android库/`
- iOS static lib + headers: `ios库/`
- Rich docs under `DOCUMENTATION/` and `doc/`

## 4) High-level Solution Outline
1. Create new app folder (e.g. `custom_camera_app/`) using `flutter create`
2. Add Clean Architecture folder structure and DI skeleton
3. Depend on existing plugin via `pubspec.yaml` path to `flutter-sdk-demo/`
4. Wrap SDK usage behind Infrastructure adapters → Data repos → Domain use cases
5. Implement core flows: connect, stream, PTZ/CGI, AI detection, alarms
6. Optimize hot paths (video frames, inference) with Isolates/Rx
7. Add tests (unit/widget/integration) and CI scripts
## 5) Folder Structure (Strict)

```
custom_camera_app/
├── android/
├── ios/
├── lib/
│  ├── core/
│  │  ├── config/                 # app_config.dart, dev/staging/prod configs
│  │  ├── constants/              # network, camera, app constants
│  │  ├── di/                     # injection_container.dart (GetIt)
│  │  ├── errors/                 # Failure hierarchy
│  │  ├── extensions/             # String, DateTime, Widget helpers
│  │  ├── logging/                # logger abstraction
│  │  └── theme/                  # colors, text styles, dimensions, theme
│  ├── features/
│  │  ├── camera_connection/
│  │  │  ├── domain/              # Entities, repos (interfaces), usecases
│  │  │  ├── data/                # repo impls, mappers, models, datasources
│  │  │  └── presentation/        # Bloc/Cubit, screens, widgets
│  │  ├── live_stream/
│  │  │  ├── domain/ data/ presentation/
│  │  ├── cgi_control/            # PTZ, settings, status
│  │  ├── ai_detection/           # AI models, inference orchestration
│  │  ├── alarms/                 # alarm subscribe/handle
│  │  └── settings/               # preferences
│  ├── infrastructure/            # SDK/API wrappers (Veepai, HTTP, storage)
│  │  ├── sdk/
│  │  │  ├── veepai/              # thin wrappers around vsdk/plugin
│  │  │  └── platform/            # platform channel helpers
│  │  ├── network/
│  │  └── storage/
│  ├── presentation/              # app_shell, routing, global widgets/state
│  └── main.dart
├── pubspec.yaml
└── test/                         # domain/data/presentation tests
```

- Dependencies must point inward only.
- Domain: pure Dart, immutable entities, use cases single-responsibility.
- Data: map Models↔Entities; never expose SDK types upstream.
- Infrastructure: SDK/platform specifics, return Models only.
- Presentation: depends only on Domain; uses UseCases, no repositories directly.
## 6) SDK Integration Strategy (Veepai)

Android:
- Consume existing AARs via plugin already provided in `flutter-sdk-demo/android` (preferred)
- Or add local AARs using Gradle `flatDir` under a Flutter plugin module if needed
- Use Kotlin coroutines for async, `Dispatchers.IO` for P2P/CGI, `Default` for CPU
- Lifecycle-aware connection; disconnect on background; reconnect on resume
- Streams via Kotlin `Flow`, marshal to Dart through event channels where needed

iOS:
- Use `ios库/libVSTC.a` and headers via existing plugin (preferred)
- Swift async/await for connect/commands; Combine for streams
- Respect `Sendable`, MainActor for UI responses; avoid retain cycles

Dart side:
- Depend on `flutter-sdk-demo` as a path dependency in `pubspec.yaml`
- Wrap plugin APIs in `infrastructure/sdk/veepai` adaptors returning DTO models
- Map DTO models to domain entities in Data layer; expose repository interfaces
- Use timeouts, retry (exponential backoff, max 3), and explicit error mapping

Key flows to cover:
- P2P connect/disconnect with state machine
- Live video playback using `AppPlayerController`
- PTZ/CGI: status, presets, motion, privacy, night mode
- Alarm subscription and handling
- AI detection toggles, result streams

Resource management:
- Dispose player/controllers on navigate away
- Close streams, cancel timers; call SDK `deviceDestroy()`
- Implement keepAlive ping (10s) while connected
## 7) Performance Plan (RxDart, Isolates, Multi-thread)

- Streams: BehaviorSubject for state; PublishSubject for events
- CombineLatest for multi-source camera state; distinct() to reduce rebuilds
- Debounce user inputs (300ms), throttle status updates (1s)
- Video frames:
  - Decode/process in dedicated Isolate; limit rate to 30 FPS
  - Object pool for frame buffers to reduce GC pressure
  - Drop frames if backlog grows beyond threshold
- AI inference:
  - Run in separate Isolate per active camera (<= num CPU cores)
  - Preload model; warm up interpreter; reuse tensors
  - Batch results and shareReplay() for UI consumers
- Widget performance:
  - const constructors, keys, RepaintBoundary around video widget
  - Keep build() < 50 lines; extract widgets; cache computed values
- Network:
  - Timeouts, retries with backoff, cache responses where safe
- Monitoring:
  - DevTools timeline; custom timing marks around connect/stream/inference
## 8) Domain Design (examples)

Entities (immutable):
- `Camera` (id, name, status, capabilities)
- `ConnectionState` (enum + details)
- `VideoStream` (source, resolution, fps)
- `AIDetection` (type, score, bbox, timestamp)
- `AlarmEvent` (type, payload, occurredAt)

Repository interfaces:
- `CameraRepository` (connect, disconnect, watchState)
- `StreamRepository` (start, stop, frames$)
- `CgiRepository` (execute, getStatus)
- `AiRepository` (load, infer, settings)
- `AlarmRepository` (subscribe, ack)

Use cases (single responsibility):
- `ConnectCameraUseCase`, `DisconnectCameraUseCase`
- `StartLiveStreamUseCase`, `StopLiveStreamUseCase`
- `SendPtzCommandUseCase`, `GetCameraStatusUseCase`
- `ToggleAiDetectionUseCase`, `RunInferenceUseCase`
- `SubscribeAlarmsUseCase`

Rules:
- No Flutter/Dart:io imports in domain
- Methods return Entities or Streams of Entities
- Errors map to typed Failures
## 9) Data & Infrastructure Design (examples)

Infrastructure (SDK wrappers):
- `VeepaiP2PClient` (connect, disconnect, state stream)
- `VeepaiPlayerAdapter` (bind view, start/stop)
- `VeepaiCgiClient` (writeCgi, waitResult, error mapping)
- `VeepaiAiAdapter` (SDK AI toggles, threshold)

Data layer:
- DTOs + mappers: never leak SDK types upward
- Repository impls orchestrate multiple sources (sdk, cache)
- Timeouts, retries, failure mapping (ConnectionTimeout, NetworkUnavailable)

Error handling:
- Central `Failure` hierarchy in core/errors
- Map SDK error codes to typed failures with user messages

Threading:
- IO-bound calls via async/await; CPU-bound via Isolate
- Streams buffered with backpressure strategy (drop/keep last)
## 10) Platform Integration Details

Android (Kotlin):
- Use `MethodChannel` and `EventChannel` per feature channel
- Coroutines + structured concurrency; choose `Dispatchers` appropriately
- LifecycleOwner aware; stop streams on `onStop`, resume on `onStart`
- Map SDK callbacks to `Flow`; use `callbackFlow` and `trySend`

iOS (Swift):
- Use `FlutterMethodChannel`; actors/async-await for async flows
- Combine for streaming; `AnyPublisher` marshalled to Dart via events
- Respect memory management; `[weak self]` in closures

Build/linking:
- Prefer existing `flutter-sdk-demo` plugin to link AAR/.a
- If custom plugin needed: set `gradle` flatDir for AARs; add `vendored_libraries` for `.a`
- CI: cache CocoaPods/Gradle; set min iOS >= 14, Android compile/target latest stable
## 11) Security & Privacy

- Never log credentials/device secrets
- Validate device IDs and authentication requirements
- Two-factor checks when required (verifyListener)
- Secure local storage (encrypted)
- Clear sensitive data on logout or uninstall

## 12) Testing Strategy

- Unit tests: 80%+ on domain use cases and repositories
- Widget tests: key widgets (video panel, connect screen)
- Integration tests: connect → stream → PTZ/CGI → disconnect
- Golden tests for UI states (online/offline/error)
- Deterministic streams via fake adapters

## 13) CI/CD & Tooling

- Lint/analyze on PR; run `flutter test` with coverage
- Build Android/iOS on CI; sign via CI secrets
- Fastlane for release; bump versions automatically
- Crash/analytics opt-in; privacy-compliant
## 14) Internet Research Highlights (as of 2025-10-16)

Flutter/Dart:
- Dart 3.x: pattern matching, records, sealed classes, extension types; `Isolate.run` utility
- Impeller rasterizer improving stability; profile rebuilds and shader warmup where needed
- Riverpod/Bloc remain mainstream; GetIt for DI; RxDart for advanced stream ops

Kotlin/Android:
- K2 compiler broadly available; Coroutines with structured concurrency; Flows for streaming
- Prefer `Dispatchers.IO` for SDK I/O and `Default` for CPU

Swift/iOS:
- Swift 6 with strict concurrency; `Sendable`, actors for shared mutable state
- Async/await and Combine first-class; MainActor for UI updates; avoid retain cycles

Plugin packaging:
- Link Android AARs via plugin Gradle; on iOS vendored `.a` with headers in podspec
- Prefer existing plugin (`flutter-sdk-demo`) to avoid rework
## 15) Actionable Task List & Milestones

M0 — Planning (this doc)
- [x] Write detailed plan and folder structure

M1 — Project Scaffold
- [ ] Create `custom_camera_app/` with `flutter create`
- [ ] Add core folder structure and DI skeleton
- [ ] Add path dependency to `flutter-sdk-demo/`

M2 — Domain Layer
- [ ] Define entities and repository interfaces
- [ ] Implement initial use cases (connect, start stream)
- [ ] Unit tests for domain

M3 — Infrastructure & Data Layer
- [ ] Wrap Veepai SDK in `infrastructure/sdk/veepai`
- [ ] Map DTOs↔entities; implement repositories
- [ ] Error mapping and retry policy
- [ ] Unit tests for data layer

M4 — Presentation Layer
- [ ] Bloc/Cubit for connect/stream/CGI/AI
- [ ] Screens: Connect, Live Stream, PTZ, AI, Alarms
- [ ] Widget tests and golden tests

M5 — Performance & AI
- [ ] Isolate-based frame and AI pipelines
- [ ] Throttle/debounce; object pooling
- [ ] Integration tests for live stream

M6 — CI/CD & Release
- [ ] Lint, tests, coverage in CI
- [ ] Android/iOS builds, signing, Fastlane
- [ ] Beta release
