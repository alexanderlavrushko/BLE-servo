//
//  ServoControlCenter.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 01/11/2021.
//

import UIKit

class ServoControlCenter {
    // MARK: - Singleton management
    static var instance: ServoControlCenter?

    private init() {
        servoModel = BLEServo()
    }

    static func create() {
        guard instance == nil else { return }
        instance = ServoControlCenter()
    }

    static func destroy() {
        instance = nil
    }

    // MARK: - Internal logic
    private let servoModel: ServoModel

    func takeControlWithViewController() -> UIViewController {
        let vc = VehicleTwoAxisViewController.loadFromNib()
        vc.viewModel = VehicleTwoAxisViewModelImpl(
            model: servoModel,
            driving: AxisOutputConfig.defaultConfig,
            steering: AxisOutputConfig(center: 112, maxNegative: 196, maxPositive: 18)
        )
        return vc
    }
}
