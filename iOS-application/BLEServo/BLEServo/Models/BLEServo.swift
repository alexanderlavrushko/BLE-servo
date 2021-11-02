//
//  BLEServo.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 22/08/2021.
//

import Foundation
import CoreBluetooth

enum BLEConnectivityState: String {
    case bluetoothNotReady
    case scanning
    case connecting
    case connectedPreparing
    case connected

    var humanReadableString: String { rawValue }
}

class BLEServo: NSObject, ServoModel, StatusModel {
    // MARK: - ServoModel implementation
    var statusModel: StatusModel { self }

    var channels = [ServoChannelModel]() { didSet { onChannelsDidChange?(channels) } }
    var onChannelsDidChange: (([ServoChannelModel]) -> Void)?

    // MARK: - StatusModel implementation
    var isConnected: Bool { state == .connected }
    var onIsConnectedDidChange: ((Bool) -> Void)?

    var statusStr: String { state.humanReadableString }
    var onStatusStrDidChange: ((String) -> Void)?

    var onError: ((String) -> Void)?

    // MARK: - Internal logic
    private(set) var state = BLEConnectivityState.bluetoothNotReady {
        didSet {
            guard state != oldValue else { return }
            log("accessory state = \(state.humanReadableString)")
            let newValue = state
            DispatchQueue.main.async {
                let wasConnected = oldValue == .connected
                let isConnected = newValue == .connected
                if isConnected != wasConnected {
                    self.onIsConnectedDidChange?(isConnected)
                }
                self.onStatusStrDidChange?(newValue.humanReadableString)
            }
        }
    }

    private let uuidService = CBUUID(string: "88F3AA10-5ACB-4CDD-9C9E-9B122D3ED93D")
    private let uuidCharPositions = CBUUID(string: "88F3AA11-5ACB-4CDD-9C9E-9B122D3ED93D")

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    private var positionWriteInProgress = false
    private var delayedSetPosition: Data?

    // methods
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        log("BLEServo init done")
    }

    deinit {
        log("BLEServo deinit")
    }
}

// MARK: - Private methods
private extension BLEServo {
    func log(_ message: String) {
        print("BLE_LOG: \(message)")
    }

    func createChannelsWithInitialPositions(_ positions: [UInt8]) {
        var newChannels = [ServoChannelModelImpl]()
        positions.forEach {
            newChannels.append(ServoChannelModelImpl(
                position: $0,
                updateHandler: { [weak self] (_) in
                    guard let self = self, self.isConnected else { return }
                    let positions = self.channels.map { $0.position }
                    self.writePositions(positions)
                }
            ))
        }
        channels = newChannels
    }

    func writePositions(_ value: [UInt8]) {
        let data = Data(value)
        if positionWriteInProgress {
            delayedSetPosition = data
        } else {
            positionWriteInProgress = true
            writeProperty(uuid: uuidCharPositions, data: data)
        }
    }
}

// MARK: - BLE related commands
private extension BLEServo {
    func startScanning() {
        state = .scanning
        centralManager.scanForPeripherals(withServices: [uuidService], options: nil)
    }

    func handleConnectionSetupFinished() {
        state = .connected
    }

    func readProperty(uuid: CBUUID) {
        guard let characteristic = getCharacteristic(uuid: uuid) else {
            log("ERROR: read failed, characteristic unavailable, uuid = \(uuid.uuidString)")
            onError?("Failed to find \(uuid.uuidString)")
            return
        }
        connectedPeripheral?.readValue(for: characteristic)
    }

    func writeProperty(uuid: CBUUID, data: Data) {
        guard let characteristic = getCharacteristic(uuid: uuid) else {
            log("ERROR: write failed, characteristic unavailable, uuid = \(uuid.uuidString)")
            onError?("Failed to find \(uuid.uuidString)")
            return
        }
        connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    func getCharacteristic(uuid: CBUUID) -> CBCharacteristic? {
        guard let service = connectedPeripheral?.services?.first(where: { $0.uuid == uuidService }) else {
            return nil
        }
        return service.characteristics?.first(where: { $0.uuid == uuid })
    }
}

// MARK: - BLE Central delegate
extension BLEServo: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        log("central.state = \(central.state.humanReadableString)")

        if central.state == .poweredOn {
            startScanning()
        } else {
            state = .bluetoothNotReady
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        log("didDiscover {name = \(peripheral.name ?? String("nil")), state = \(peripheral.state.humanReadableString)}")

        guard connectedPeripheral == nil else {
            log("didDiscover ignored (connectedPeripheral already set)")
            return
        }

        connectedPeripheral = peripheral
        state = .connecting
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("didConnect")
        state = .connectedPreparing

        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([uuidService])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        log("didFailToConnect, error = \(String(describing: error))")
        onError?("didFailToConnect: \(String(describing: error))")
        connectedPeripheral = nil
        startScanning()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        log("didDisconnectPeripheral, error = \(String(describing: error))")
        connectedPeripheral = nil
        startScanning()
    }
}

// MARK: - BLE Peripheral delegate
extension BLEServo: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == uuidService }) else {
            log("ERROR: didDiscoverServices, service NOT found")
            onError?("Service not found (restart the phone may help)")
            return
        }

        log("didDiscoverServices, service found")
        peripheral.discoverCharacteristics([uuidCharPositions], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        log("didDiscoverCharacteristics \(error == nil ? "OK" : "error: \(String(describing: error))")")

        positionWriteInProgress = false
        delayedSetPosition = nil

        readProperty(uuid: uuidCharPositions)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            log("ERROR: didUpdateValueFor error = \(String(describing: error))")
            onError?("didUpdateValueFor: \(String(describing: error))")
            return
        }

        if characteristic.uuid == uuidCharPositions {
            var positions = [UInt8]()
            characteristic.value?.withUnsafeBytes({ rawBufferPtr in
                positions += rawBufferPtr[0..<rawBufferPtr.count]
            })

            createChannelsWithInitialPositions(positions)

            if state == .connectedPreparing {
                handleConnectionSetupFinished()
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            log("ERROR: didWriteValueFor: \(String(describing: error))")
            onError?("Write failed: \(String(describing: error))")
            return
        }

        if (characteristic.uuid == uuidCharPositions) {
            if let newValue = delayedSetPosition {
                delayedSetPosition = nil
                writeProperty(uuid: uuidCharPositions, data: newValue)
            } else {
                positionWriteInProgress = false
            }
        }
    }
}
