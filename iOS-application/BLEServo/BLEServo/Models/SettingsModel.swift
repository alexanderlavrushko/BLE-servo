//
//  SettingsModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import Foundation

/// This protocol defines how ViewModel communicates with Model. Just to make the dependency clear.
protocol SettingsModel: AnyObject {
    var controlType: ControlType { get set }
}

enum ControlType: String {
    case twoHorizontalSliders
    case fourButtons
}
