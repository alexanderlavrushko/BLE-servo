# SwiftUI migration guide

## Decisions

- The application now uses Swift 6 language mode with complete strict-concurrency checking and an iOS 17.0 deployment target. This makes the Observation framework available throughout the app.
- View models use `@Observable` and are isolated to `@MainActor` because they drive UI state and timers. Views use SwiftUI `@State` for owned view models and `@Bindable` for editable or observed state. `ObservableObject` and Combine are not needed.
- `BLEServo` remains the delegate-based CoreBluetooth implementation. CoreBluetooth is callback-driven, and forcing it through continuations or an artificial async API would add risk without improving this app's behavior. `BLEServoAdapter` observes the existing model callbacks and refreshes its SwiftUI-facing state on the main actor.
- The CoreBluetooth manager already uses its default main queue. The BLE model and BLE-created channel implementation have narrowly scoped `@unchecked Sendable` conformances for Swift 6's main-queue callback handoffs; the SwiftUI-facing view models remain main-actor isolated.
- Existing servo conversion, persisted settings, animation rates, channel selection, presets, and control-mode behavior remain in their original model/view-model responsibilities. SwiftUI views replace only the presentation layer and use native controls, focus state, and keyboard toolbar dismissal.

## Structure

Before:

```text
AppDelegate / SceneDelegate / Main.storyboard
  -> MainViewController
    -> ServoControlCenter singleton
      -> UIKit view controllers loaded from XIBs
        -> closure-connected view models
          -> BLEServo / SettingsModelImpl
```

After:

```text
BLEServoApp (SwiftUI App)
  -> WindowGroup / NavigationStack
    -> ServoControlCenter (owned dependency assembly)
      -> BLEServoAdapter (@Observable)
        -> BLEServo (CoreBluetooth delegates)
      -> observable screen/control view models
        -> SwiftUI pages and controls
      -> SettingsModelImpl (UserDefaults persistence)
```

`ServoControlCenter` is constructed once by the app and passed into the root view. It owns the settings model, settings view model, and BLE adapter, and creates control-mode view models. When Settings closes, a revision change recreates the active control view so new channel, mapping, and animation settings take effect immediately. The adapter retains the delegate-driven BLE implementation as its source of truth; callback events refresh adapter properties that SwiftUI observes.

## Files and responsibilities

- `BLEServo/BLEServo/TopLevelApp/AppDelegate.swift` now contains `BLEServoApp`, the `@main` SwiftUI entry point.
- `BLEServo/BLEServo/TopLevelApp/MainViewController.swift` now contains the `MainView` navigation root and routes between the two persisted control modes.
- `BLEServo/BLEServo/TopLevelApp/ServoControlCenter.swift` is the composition root and defines the observable BLE adapter.
- `BLEServo/BLEServo/ViewsAndViewModels/Pages/VehicleTwoAxisViewController.swift` and `VehicleButtonsViewController.swift` now define the two SwiftUI control pages. `SettingsViewController.swift` now defines the SwiftUI settings screen.
- The control files `AxisView.swift`, `StatusView.swift`, `ButtonsHAxisView.swift`, `ButtonsVAxisView.swift`, and `ChannelSettingsView.swift` now define SwiftUI controls. `AxisRenderValueView.swift` renders the existing centered movement indicator with SwiftUI shapes.
- View-model implementations in `ViewsAndViewModels/` now use Observation rather than view-update callbacks. `AxisConverter.swift` and `ValueAnimator.swift` retain the conversion and timed-animation responsibilities.
- `Models/BLEServo.swift` remains delegate-based. `Models/ServoChannelModel.swift` adds only the sendability annotation required for the existing main-queue callback under Swift 6.
- `BLEServo.xcodeproj/project.pbxproj` removes XIB and UIKit helper references and sets Swift 6, complete strict concurrency checking, and iOS 17. `Info.plist` no longer selects a UIKit scene delegate or main storyboard. The launch-screen storyboard and asset catalog remain.
- `MIGRATION_GUIDE.md` documents the migration and maintenance path.

The XIB layouts and UIKit nib helpers have been removed. `SceneDelegate.swift`, `Main.storyboard`, `UIViewWithNib.swift`, `UIViewController+loadFromNib.swift`, `UIView+extension.swift`, `NumericTextField.swift`, and the UIKit-only axis-rendering view model are no longer needed.

## Extending the app

1. Keep CoreBluetooth discovery, connection, and writes in `BLEServo`; expose new callback-backed values through `BLEServoAdapter`.
2. Keep presentation state on `@MainActor @Observable` view models. Make SwiftUI views observe those models instead of adding closure callback chains.
3. Add UI in the existing SwiftUI controls or pages and construct dependencies in `ServoControlCenter`.
4. Persist user preferences through `SettingsModelImpl` and keep servo conversion or animation logic in the existing logic/model layer.
5. If a new callback crosses a concurrency boundary, ensure its value is `Sendable` or perform a safe main-actor refresh from the adapter. Avoid broadening unchecked sendability beyond the existing main-queue BLE handoff.

## Validation

There are no test targets in the project. `swiftc -frontend -parse` can be used for a syntax-only check, but a full build requires Xcode and an iOS SDK:

```sh
xcodebuild -project BLEServo.xcodeproj -scheme BLEServo -configuration Debug build
```
