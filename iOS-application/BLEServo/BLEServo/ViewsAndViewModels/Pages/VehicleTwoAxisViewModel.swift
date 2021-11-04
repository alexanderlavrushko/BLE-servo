//
//  VehicleTwoAxisViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 31/10/2021.
//

import Foundation

/// This protocol defines how View communicates with ViewModel. Just to make the dependency clear.
protocol VehicleTwoAxisViewModel: AnyObject {
    var statusViewModel: StatusViewModel { get }
    var onStatusViewModelDidChange: ((StatusViewModel) -> Void)? { get set }

    var drivingViewModel: AxisViewModel { get }
    var onDrivingViewModelDidChange: ((AxisViewModel) -> Void)? { get set }

    var steeringViewModel: AxisViewModel { get }
    var onSteeringViewModelDidChange: ((AxisViewModel) -> Void)? { get set }
}

class VehicleTwoAxisViewModelImpl: VehicleTwoAxisViewModel {
    // MARK: - VehicleTwoAxisViewModel implementation
    var statusViewModel: StatusViewModel { didSet { onStatusViewModelDidChange?(statusViewModel) } }
    var onStatusViewModelDidChange: ((StatusViewModel) -> Void)?

    var drivingViewModel: AxisViewModel { drivingAxis }
    var onDrivingViewModelDidChange: ((AxisViewModel) -> Void)?

    var steeringViewModel: AxisViewModel { steeringAxis }
    var onSteeringViewModelDidChange: ((AxisViewModel) -> Void)?

    // MARK: - Internal logic
    let model: ServoModel
    let drivingConfig: AxisOutputConfig
    let steeringConfig: AxisOutputConfig
    var drivingAxis: AxisViewModelImpl! { didSet { onDrivingViewModelDidChange?(drivingViewModel) } }
    var steeringAxis: AxisViewModelImpl! { didSet { onSteeringViewModelDidChange?(steeringViewModel) } }

    init(model: ServoModel, driving: AxisOutputConfig, steering: AxisOutputConfig) {
        self.model = model
        drivingConfig = driving
        steeringConfig = steering
        statusViewModel = StatusViewModelImpl(model: model.statusModel)
        connectToModel()
    }
}

private extension VehicleTwoAxisViewModelImpl {
    func connectToModel() {
        model.onChannelsDidChange = { [weak self] (_) in
            self?.connectToChannels()
        }
        connectToChannels()
    }

    func connectToChannels() {
        drivingAxis = AxisViewModelImpl(
            model: getChannel(index: 0),
            axisName: "Driving",
            config: drivingConfig
        )
        steeringAxis = AxisViewModelImpl(
            model: getChannel(index: 1),
            axisName: "Steering",
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
