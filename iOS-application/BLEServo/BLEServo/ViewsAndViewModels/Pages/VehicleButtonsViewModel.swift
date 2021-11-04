//
//  VehicleButtonsViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 03/11/2021.
//

import Foundation

/// This protocol defines how View communicates with ViewModel. Just to make the dependency clear.
protocol VehicleButtonsViewModel: AnyObject {
    var statusViewModel: StatusViewModel { get }
    var onStatusViewModelDidChange: ((StatusViewModel) -> Void)? { get set }

    var drivingViewModel: ButtonsAxisViewModel { get }
    var onDrivingViewModelDidChange: ((ButtonsAxisViewModel) -> Void)? { get set }

    var steeringViewModel: ButtonsAxisViewModel { get }
    var onSteeringViewModelDidChange: ((ButtonsAxisViewModel) -> Void)? { get set }
}

class VehicleButtonsViewModelImpl: VehicleButtonsViewModel {
    // MARK: - VehicleButtonsViewModel implementation
    var statusViewModel: StatusViewModel { didSet { onStatusViewModelDidChange?(statusViewModel) } }
    var onStatusViewModelDidChange: ((StatusViewModel) -> Void)?

    var drivingViewModel: ButtonsAxisViewModel { drivingAxis }
    var onDrivingViewModelDidChange: ((ButtonsAxisViewModel) -> Void)?

    var steeringViewModel: ButtonsAxisViewModel { steeringAxis }
    var onSteeringViewModelDidChange: ((ButtonsAxisViewModel) -> Void)?

    // MARK: - Internal logic
    let model: ServoModel
    let drivingConfig: AxisOutputConfig
    let steeringConfig: AxisOutputConfig
    var drivingAxis: ButtonsAxisViewModelImpl! { didSet { onDrivingViewModelDidChange?(drivingViewModel) } }
    var steeringAxis: ButtonsAxisViewModelImpl! { didSet { onSteeringViewModelDidChange?(steeringViewModel) } }

    init(model: ServoModel, driving: AxisOutputConfig, steering: AxisOutputConfig) {
        self.model = model
        drivingConfig = driving
        steeringConfig = steering
        statusViewModel = StatusViewModelImpl(model: model.statusModel)
        connectToModel()
    }
}

private extension VehicleButtonsViewModelImpl {
    func connectToModel() {
        model.onChannelsDidChange = { [weak self] (_) in
            self?.connectToChannels()
        }
        connectToChannels()
    }

    func connectToChannels() {
        drivingAxis = ButtonsAxisViewModelImpl(
            model: getChannel(index: 0),
            config: drivingConfig
        )
        steeringAxis = ButtonsAxisViewModelImpl(
            model: getChannel(index: 1),
            config: steeringConfig
        )
    }

    func getChannel(index: Int) -> ServoChannelModel {
        if index < model.channels.count {
            return model.channels[index]
        }
        return ServoChannelModelStub()
    }
}
