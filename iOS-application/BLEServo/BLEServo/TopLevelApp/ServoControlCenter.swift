import Observation
import SwiftUI

@MainActor
@Observable
final class ServoControlCenter {
    let settingsModel: SettingsModel
    let settingsViewModel: SettingsViewModelImpl
    let ble: BLEServoAdapter

    init() {
        let settingsModel = SettingsModelImpl()
        self.settingsModel = settingsModel
        settingsViewModel = SettingsViewModelImpl(model: settingsModel)
        ble = BLEServoAdapter(model: BLEServo())
    }

    func makeTwoAxisViewModel() -> VehicleTwoAxisViewModelImpl {
        VehicleTwoAxisViewModelImpl(
            model: ble,
            driving: settingsModel.drivingModel.data,
            steering: settingsModel.steeringModel.data
        )
    }

    func makeButtonsViewModel() -> VehicleButtonsViewModelImpl {
        VehicleButtonsViewModelImpl(
            model: ble,
            driving: settingsModel.drivingModel.data,
            steering: settingsModel.steeringModel.data
        )
    }
}

@MainActor
@Observable
final class BLEServoAdapter {
    private let model: BLEServo

    var channels: [ServoChannelModel]
    var isConnected: Bool
    var statusStr: String
    var errorText: String?


    init(model: BLEServo) {
        self.model = model
        channels = model.channels
        isConnected = model.isConnected
        statusStr = model.statusStr

        model.onChannelsDidChange = { [weak self] _ in
            Task { @MainActor [weak self] in self?.refresh() }
        }
        model.onIsConnectedDidChange = { [weak self] _ in
            Task { @MainActor [weak self] in self?.refresh() }
        }
        model.onStatusStrDidChange = { [weak self] _ in
            Task { @MainActor [weak self] in self?.refresh() }
        }
        model.onError = { [weak self] error in
            Task { @MainActor [weak self] in self?.errorText = error }
        }
    }

    private func refresh() {
        channels = model.channels
        isConnected = model.isConnected
        statusStr = model.statusStr
    }
}
