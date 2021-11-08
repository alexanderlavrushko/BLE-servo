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
        settingsModel = SettingsModelImpl()
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
    private let settingsModel: SettingsModel

    func takeControl() -> UIViewController {
        switch settingsModel.controlType {
        case .twoHorizontalSliders:
            return takeControlWithAxis()
        case .fourButtons:
            return takeControlWithButtons()
        }
    }

    func makeSettingsViewController(onDismiss: @escaping (() -> Void)) -> UIViewController {
        let settingsVC = SettingsViewController.loadFromNib()
        settingsVC.viewModel = SettingsViewModelImpl(model: settingsModel)
        settingsVC.onDismiss = onDismiss
        return settingsVC
    }
}

private extension ServoControlCenter {
    func takeControlWithAxis() -> UIViewController {
        let vc = VehicleTwoAxisViewController.loadFromNib()
        vc.viewModel = VehicleTwoAxisViewModelImpl(
            model: servoModel,
            driving: AxisOutputConfig.defaultConfig,
            steering: AxisOutputConfig(center: 112, maxNegative: 196, maxPositive: 18)
        )
        return vc
    }

    func takeControlWithButtons() -> UIViewController {
        let vc = VehicleButtonsViewController.loadFromNib()
        vc.viewModel = VehicleButtonsViewModelImpl(
            model: servoModel,
            driving: AxisOutputConfig.defaultConfig,
            steering: AxisOutputConfig(center: 112, maxNegative: 196, maxPositive: 18)
        )
        return vc
    }
}
