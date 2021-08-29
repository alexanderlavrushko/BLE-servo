//
//  Extensions.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 22/08/2021.
//

import Foundation
import CoreBluetooth

extension CBManagerState {
    var humanReadableString: String {
        switch self {
        case .unknown: return "unknown"
        case .resetting: return "resetting"
        case .unsupported: return "unsupported"
        case .unauthorized: return "unauthorized"
        case .poweredOff: return "poweredOff"
        case .poweredOn: return "poweredOn"
        @unknown default: return "other=\(rawValue)"
        }
    }
}

extension CBPeripheralState {
    var humanReadableString: String {
        switch self {
        case .disconnected: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .disconnecting: return "disconnecting"
        @unknown default: return "other=\(rawValue)"
        }
    }
}
