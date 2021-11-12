//
//  SettingsModelImpl.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import Foundation

class SettingsModelImpl: SettingsModel {
    // MARK: - SettingsModel implementation
    @UserDefault(key: .controlType, defaultValue: .twoHorizontalSliders)
    var controlType: ControlType
}

private enum SettingsKey: String {
    case controlType

    var key: String {
        "settings.\(rawValue)"
    }
}

@propertyWrapper
struct UserDefault<ValueType: RawRepresentable> where ValueType.RawValue == String {
    fileprivate let key: SettingsKey
    let defaultValue: ValueType
    var container: UserDefaults { .standard }

    var wrappedValue: ValueType {
        get { container.read(key) ?? defaultValue }
        set { container.write(newValue, key: key) }
    }
}

private extension UserDefaults {
    func read<ValueType: RawRepresentable>(_ key: SettingsKey) -> ValueType? where ValueType.RawValue == String {
        if let str = string(forKey: key.key) {
            return ValueType(rawValue: str)
        }
        return nil
    }

    func write<ValueType: RawRepresentable>(_ value: ValueType?, key: SettingsKey) where ValueType.RawValue == String {
        set(value?.rawValue, forKey: key.key)
    }
}
