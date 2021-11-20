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

    var drivingModel: ChannelSettingsModel { drivingImpl }
    var steeringModel: ChannelSettingsModel { steeringImpl }

    func resetToDefaults() {
        SettingsKey.allCases.forEach { key in
            UserDefaults.standard.set(nil, forKey: key.key)
        }
    }

    private var drivingImpl = ChannelSettingsModelImpl(
        key: .driving,
        defaultValue: ChannelSettingsData(
            channelIndex: 0,
            outputConfig: .defaultConfig,
            animationSpeed: 2
        )
    )
    private var steeringImpl = ChannelSettingsModelImpl(
        key: .steering,
        defaultValue: ChannelSettingsData(
            channelIndex: 1,
            outputConfig: .defaultConfig,
            animationSpeed: 2
        )
    )
}

private class ChannelSettingsModelImpl: ChannelSettingsModel {
    // MARK: - ChannelSettingsModel implementation
    @UserDefault var data: ChannelSettingsData

    // MARK: - Internal logic
    init(key: SettingsKey, defaultValue: ChannelSettingsData) {
        _data = UserDefault(key: key, defaultValue: defaultValue)
    }
}

private enum SettingsKey: String, CaseIterable {
    case controlType
    case driving
    case steering

    var key: String {
        "settings.\(rawValue)"
    }
}

@propertyWrapper
struct UserDefault<ValueType> where ValueType: Codable {
    fileprivate let key: SettingsKey
    let defaultValue: ValueType
    var container: UserDefaults { .standard }

    var wrappedValue: ValueType {
        get { container.read(key) ?? defaultValue }
        set { container.write(newValue, key: key) }
    }
}

private extension UserDefaults {
    func read<ValueType>(_ key: SettingsKey) -> ValueType? where ValueType: Decodable {
        guard let data = data(forKey: key.key) else { return nil }
        return try? JSONDecoder().decode(ValueType.self, from: data)
    }

    func write<ValueType>(_ value: ValueType?, key: SettingsKey) where ValueType: Encodable {
        let data = { () -> Data? in
            if let value = value {
                return try? JSONEncoder().encode(value)
            }
            return nil
        }()
        set(data, forKey: key.key)
    }
}
