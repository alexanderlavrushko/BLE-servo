# BLE-servo

BLE-servo contains:
- iOS app (`/iOS-application/BLEServo`) acting as BLE Central
- nRF51822 firmware (`/nRF51-servo`) acting as BLE Peripheral
- Android app (`/Android-application/BLEServoAndroid`) acting as BLE Central (new)

## Reverse-engineered BLE protocol (iOS + firmware parity)

Source of truth:
- iOS central: `/iOS-application/BLEServo/BLEServo/Models/BLEServo.swift`
- Peripheral service: `/nRF51-servo/ble_service_servo.h`, `/nRF51-servo/ble_service_servo.c`, `/nRF51-servo/main.c`

### UUIDs
- Service: `88F3AA10-5ACB-4CDD-9C9E-9B122D3ED93D`
- Position characteristic (read/write with response): `88F3AA11-5ACB-4CDD-9C9E-9B122D3ED93D`
- Count characteristic (read-only): `88F3AA12-5ACB-4CDD-9C9E-9B122D3ED93D`

### Payload format
- Position characteristic value is a raw byte array.
- Each byte is one servo channel value in range `[0..255]`.
- Current firmware uses 2 channels (`SERVO_COUNT=2`):
  - `channel 0` = driving
  - `channel 1` = steering

### BLE flow
1. Scan by service UUID
2. Connect
3. Discover service and position characteristic
4. Read initial position bytes once
5. Write full position bytes on every control change (with response)
6. Reconnect after disconnect/failure

## Android app

Path: `/Android-application/BLEServoAndroid`

Architecture:
- BLE transport: `ble/BleServoTransport.kt`
- Protocol/command layer: `protocol/ServoBleProtocol.kt`, `protocol/AxisConversion.kt`
- UI/state layer: `ui/MainViewModel.kt`, `ui/MainActivity.kt`

Implemented Android behavior:
- BLE scanning with service filter
- Device list + manual selection + connect/disconnect
- GATT connection lifecycle with reconnect attempts and stale GATT close
- Initial read of current servo positions
- Serialized BLE operations (read/write queue) and write coalescing
- MTU negotiation request (`requestMtu(128)` then service discovery)
- Two-servo controls with iOS-compatible axis mapping
- Slider mode (auto return to center) and button mode (press/release animation)
- Presets: `Default` and `My Car` (same values as iOS settings preset)
- BLE event and command logs in UI

## Build / run (Android)

From repository root:

```bash
cd /home/runner/work/BLE-servo/BLE-servo/Android-application/BLEServoAndroid
./gradlew assembleDebug
```

Install debug build (example):

```bash
./gradlew installDebug
```

Run from Android Studio:
1. Open `/home/runner/work/BLE-servo/BLE-servo/Android-application/BLEServoAndroid`
2. Let Gradle sync
3. Run `app` on a real Android device with BLE

## Android BLE permission matrix

| Android API | Required runtime permissions | Notes |
|---|---|---|
| 31+ (Android 12+) | `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` | `BLUETOOTH_SCAN` is requested with `neverForLocation` in manifest |
| 23-30 | `ACCESS_FINE_LOCATION` | Needed for BLE scan results on these API levels |
| <23 | none at runtime | Not a target use case for this app |

## nRF51822 firmware assumptions

- Firmware advertises service `88F3AA10-5ACB-4CDD-9C9E-9B122D3ED93D`
- Position characteristic supports read and write
- Channel count is 2
- Initial positions are centered (`127`, `127`)
- Writing 2 bytes updates PWM for both servos immediately

## Troubleshooting (Android BLE)

- **No devices found**
  - Ensure peripheral is powered and advertising
  - Confirm Bluetooth is ON and required runtime permissions are granted
- **Connect succeeds, no control effect**
  - Verify service/characteristic UUIDs on firmware build
  - Check log area for write status and GATT errors
- **Frequent disconnects**
  - Move device closer, reduce RF interference
  - Toggle Bluetooth and reconnect
  - Reboot peripheral to clear stale stack state
- **Wrong steering direction/range**
  - Switch to `My Car` preset (inverted steering map like iOS preset)

## Parity checklist (iOS vs Android)

| Feature | iOS app | Android app | Status |
|---|---|---|---|
| BLE scan by servo service UUID | Yes | Yes | ✅ |
| Connect/disconnect lifecycle | Yes | Yes | ✅ |
| Read initial servo positions | Yes | Yes | ✅ |
| Write positions with response | Yes | Yes | ✅ |
| Two servo channels control | Yes | Yes | ✅ |
| Slider-style control with return-to-center | Yes | Yes | ✅ |
| Button-style control (press/release) | Yes | Yes | ✅ |
| Preset "My Car" mapping | Yes | Yes | ✅ |
| Count characteristic usage | Firmware has it; iOS does not use | Firmware has it; Android currently does not use | ➖ intentional |
| Persistent settings storage | Yes (UserDefaults) | Not yet persisted across app restarts | ⚠️ gap |

## Test plan

Manual:
1. Grant required Bluetooth permissions
2. Scan and select peripheral advertising servo service UUID
3. Connect and verify state reaches `Ready`
4. Confirm initial servo values appear from characteristic read
5. Move driving/steering sliders and verify both servos react
6. Release slider and verify return-to-center behavior
7. Use button mode and verify press/release behavior
8. Switch `Default` / `My Car` presets and verify mapping changes
9. Disconnect and reconnect, verify control recovers

Automated (basic):
- Unit tests for protocol encoding/decoding and axis conversion:
  - `app/src/test/java/com/alexanderlavrushko/bleservo/protocol/ServoProtocolTest.kt`
