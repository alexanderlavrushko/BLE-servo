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

extension Comparable {
    func clamped(_ min: Self, _ max: Self) -> Self {
        var result = self
        if result < min {
            result = min
        } else if result > max {
            result = max
        }
        return result
    }

    func clampedAutoMinMax(_ value1: Self, _ value2: Self) -> Self {
        clamped(min(value1, value2), max(value1, value2))
    }
}

extension Float {
    var safeUInt8: UInt8 {
        if self < Float(UInt8.min) {
            return UInt8.min
        } else if self > Float(UInt8.max) {
            return UInt8.max
        }
        return UInt8(self)
    }
}
