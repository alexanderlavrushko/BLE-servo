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

    // MARK: - Internal logic
    private var model: SettingsModel

    init(model: SettingsModel) {
        self.model = model
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
