import Observation

@MainActor
@Observable
final class VehicleTwoAxisViewModelImpl {
    let statusViewModel: StatusViewModelImpl
    private(set) var drivingViewModel: AxisViewModelImpl
    private(set) var steeringViewModel: AxisViewModelImpl

    private let model: BLEServoAdapter
    private let drivingSettings: ChannelSettingsData
    private let steeringSettings: ChannelSettingsData

    init(model: BLEServoAdapter, driving: ChannelSettingsData, steering: ChannelSettingsData) {
        self.model = model
        drivingSettings = driving
        steeringSettings = steering
        statusViewModel = StatusViewModelImpl(model: model)
        drivingViewModel = Self.makeAxisViewModel("Driving", settings: driving, model: model)
        steeringViewModel = Self.makeAxisViewModel("Steering", settings: steering, model: model)
    }

    func channelsDidChange() {
        drivingViewModel = Self.makeAxisViewModel("Driving", settings: drivingSettings, model: model)
        steeringViewModel = Self.makeAxisViewModel("Steering", settings: steeringSettings, model: model)
    }

    private static func makeAxisViewModel(
        _ name: String,
        settings: ChannelSettingsData,
        model: BLEServoAdapter
    ) -> AxisViewModelImpl {
        AxisViewModelImpl(
            model: channel(index: settings.channelIndex, in: model),
            axisName: name,
            config: settings.outputConfig,
            animationSpeed: settings.animationSpeed
        )
    }

    private static func channel(index: UInt8, in model: BLEServoAdapter) -> ServoChannelModel {
        guard Int(index) < model.channels.count else { return ServoChannelModelStub() }
        return model.channels[Int(index)]
    }
}
