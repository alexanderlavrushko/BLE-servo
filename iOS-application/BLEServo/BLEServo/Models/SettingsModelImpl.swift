//
//  SettingsModelImpl.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import Foundation

class SettingsModelImpl: SettingsModel {
    // MARK: - SettingsModel implementation
    var controlType: ControlType {
        get { controlTypeInternal.value }
        set { controlTypeInternal.value = newValue }
    }

    // MARK: - Internal logic
    private var controlTypeInternal = Stored<ControlType>(key: .controlType, defaultValue: .twoHorizontalSliders)
}

private enum SettingsKey: String {
    case controlType

    var key: String {
        "settings.\(rawValue)"
    }
}

private class Stored<ValueType: RawRepresentable> where ValueType.RawValue == String {
    let key: SettingsKey
    let defaultValue: ValueType

    var value: ValueType {
        get { UserDefaults.standard.read(key) ?? defaultValue }
        set { UserDefaults.standard.write(newValue, key: key)}
    }

    init(key: SettingsKey, defaultValue: ValueType) {
        self.key = key
        self.defaultValue = defaultValue
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
