//
//  SettingsModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import Foundation

// MARK: - Top-level protocol
/// This protocol defines how ViewModel communicates with Model. Just to make the dependency clear.
protocol SettingsModel: AnyObject {
    var controlType: ControlType { get set }
    var drivingModel: ChannelSettingsModel { get }
    var steeringModel: ChannelSettingsModel { get }
    func resetToDefaults()
}

// MARK: - Types used by top-level protocol
enum ControlType: String, Codable {
    case twoHorizontalSliders
    case fourButtons
}

/// This protocol defines how ViewModel communicates with Model. Just to make the dependency clear.
protocol ChannelSettingsModel: AnyObject {
    var data: ChannelSettingsData { get set }
}

struct ChannelSettingsData: Codable {
    var channelIndex: UInt8
    var outputConfig: AxisOutputConfig
    var animationSpeed: Float
}
