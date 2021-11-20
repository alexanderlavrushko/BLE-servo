//
//  AxisConverter.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/09/2021.
//

import Foundation

/// Defines how to convert an input "axis" value (Float) to an output "servo" value (UInt8).
/// Input range is constant: [-1, 1], 0.0 means center.
/// Output range is configurable:
/// - can also be asymmetric (different output ranges for positive and negative input values)
/// - can also be inverted (output values increase for negative inputs and decrease for positive inputs)
struct AxisOutputConfig: Codable {
    /// An output value for an input value of Float(0).
    var center: UInt8
    /// An output value for an input value of Float(-1).
    var maxNegative: UInt8
    /// An output value for an input value of Float(1).
    var maxPositive: UInt8

    static var defaultConfig: AxisOutputConfig {
        AxisOutputConfig(center: 127, maxNegative: 0, maxPositive: 255)
    }
}

/// Converts "axis" input values to "servo" output values.
/// "Axis" input is a joystick-style Float value [-1, 1], 0.0 represents a center.
/// "Servo" output is a UInt8 value which will be sent to a connected servo controller.
class AxisConverter {
    let output: AxisOutputConfig

    var negativeToCenter: Float { Float(output.center) - Float(output.maxNegative) }
    var centerToPositive: Float { Float(output.maxPositive) - Float(output.center) }

    init(_ outputConfig: AxisOutputConfig) {
        output = outputConfig
    }

    func axisToServo(_ value: Float) -> UInt8 {
        let inputValue = value.clamped(-1, 1)
        let maxDeltaFromCenter = { () -> Float in
            if inputValue < 0 {
                return negativeToCenter
            } else {
                return centerToPositive
            }
        }()
        return (Float(output.center) + inputValue * maxDeltaFromCenter).safeUInt8
    }

    func servoToAxis(_ value: UInt8) -> Float {
        let inputValue = value.clampedAutoMinMax(output.maxNegative, output.maxPositive)
        var maxDelta = centerToPositive
        if (output.maxNegative < output.maxPositive && value < output.center) ||
            (output.maxNegative > output.maxPositive && value > output.center) {
            maxDelta = negativeToCenter
        }
        return (Float(inputValue) - Float(output.center)) / maxDelta
    }
}
