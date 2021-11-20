//
//  SettingsViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 08/11/2021.
//

import UIKit

/// This protocol defines how View communicates with ViewModel. Just to make the dependency clear.
protocol SettingsViewModel: AnyObject {
    var controlTypeIndex: Int { get set }
    var allControlTypeImages: [UIImage] { get }

    var drivingViewModel: ChannelSettingsViewModel { get }
    var steeringViewModel: ChannelSettingsViewModel { get }

    var onNeedToReloadValues: (() -> Void)? { get set }
    func restorePresetMyCar()
    func resetToDefaults()
}

class SettingsViewModelImpl: SettingsViewModel {
    // MARK: - SettingsViewModel implementation
    var controlTypeIndex: Int {
        get {
            ControlTypeIndex(model.controlType).rawValue
        }
        set {
            guard let index = ControlTypeIndex(rawValue: newValue) else { return }
            model.controlType = index.controlType
        }
    }
    var allControlTypeImages: [UIImage] {
        ControlTypeIndex.allCases.map {
            UIImage(named: $0.imageName) ?? UIImage.actions
        }
    }

    var drivingViewModel: ChannelSettingsViewModel { drivingImpl }
    var steeringViewModel: ChannelSettingsViewModel { steeringImpl }

    var onNeedToReloadValues: (() -> Void)?

    func restorePresetMyCar() {
        model.controlType = .twoHorizontalSliders
        model.drivingModel.data = ChannelSettingsData(
            channelIndex: 0,
            outputConfig: AxisOutputConfig(center: 127, maxNegative: 10, maxPositive: 245),
            animationSpeed: 2
        )
        model.steeringModel.data = ChannelSettingsData(
            channelIndex: 1,
            outputConfig: AxisOutputConfig(center: 112, maxNegative: 196, maxPositive: 18),
            animationSpeed: 2
        )
        onNeedToReloadValues?()
    }

    func resetToDefaults() {
        model.resetToDefaults()
        onNeedToReloadValues?()
    }

    // MARK: - Internal logic
    private var model: SettingsModel
    var drivingImpl: ChannelSettingsViewModelImpl
    var steeringImpl: ChannelSettingsViewModelImpl

    init(model: SettingsModel) {
        self.model = model
        drivingImpl = ChannelSettingsViewModelImpl(model: model.drivingModel)
        steeringImpl = ChannelSettingsViewModelImpl(model: model.steeringModel)
    }
}

private enum ControlTypeIndex: Int, CaseIterable {
    case sliders = 0
    case buttons = 1

    init(_ type: ControlType) {
        switch type {
        case .twoHorizontalSliders: self = .sliders
        case .fourButtons: self = .buttons
        }
    }

    var controlType: ControlType {
        switch self {
        case .sliders: return .twoHorizontalSliders
        case .buttons: return .fourButtons
        }
    }

    var imageName: String {
        switch self {
        case .sliders:
            return "CarSliders"
        case .buttons:
            return "CarButtons"
        }
    }
}
