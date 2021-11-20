//
//  ChannelSettingsViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 19/11/2021.
//

import Foundation

/// This protocol defines how View communicates with ViewModel. Just to make the dependency clear.
protocol ChannelSettingsViewModel: AnyObject {
    func updateMappingNegative(wantedValue: String?) -> String
    func updateMappingCenter(wantedValue: String?) -> String
    func updateMappingPositive(wantedValue: String?) -> String
    func updateChannelIndex(wantedValue: String?) -> String
    func updateAnimationSpeed(wantedValue: String?) -> String
}

class ChannelSettingsViewModelImpl: ChannelSettingsViewModel {
    // MARK: - ChannelSettingsViewModel implementation
    func updateMappingNegative(wantedValue: String?) -> String {
        if let newValue = UInt8(wantedValue) {
            model.data.outputConfig.maxNegative = newValue
        }
        return "\(model.data.outputConfig.maxNegative)"
    }

    func updateMappingCenter(wantedValue: String?) -> String {
        if let newValue = UInt8(wantedValue) {
            model.data.outputConfig.center = newValue
        }
        return "\(model.data.outputConfig.center)"
    }

    func updateMappingPositive(wantedValue: String?) -> String {
        if let newValue = UInt8(wantedValue) {
            model.data.outputConfig.maxPositive = newValue
        }
        return "\(model.data.outputConfig.maxPositive)"
    }

    func updateChannelIndex(wantedValue: String?) -> String {
        if let newValue = UInt8(wantedValue) {
            model.data.channelIndex = newValue
        }
        return "\(model.data.channelIndex)"
    }

    func updateAnimationSpeed(wantedValue: String?) -> String {
        if let newValue = Float(wantedValue, min: 0.1, max: 1000) {
            model.data.animationSpeed = newValue
        }
        return "\(model.data.animationSpeed)"
    }

    // MARK: - Internal logic
    private let model: ChannelSettingsModel

    init(model: ChannelSettingsModel) {
        self.model = model
    }
}

private extension UInt8 {
    init?(_ text: String?) {
        guard let text = text, !text.isEmpty else {
            return nil
        }
        self.init(text)
    }
}

private extension Float {
    init?(_ text: String?, min: Float, max: Float) {
        guard let text = text,
              !text.isEmpty,
              let value = Float(text) else {
            return nil
        }
        self = value.clamped(min, max)
    }
}
