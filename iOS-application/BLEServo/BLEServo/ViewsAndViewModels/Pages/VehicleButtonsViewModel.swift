import Observation

@MainActor
@Observable
final class VehicleButtonsViewModelImpl {
    let statusViewModel: StatusViewModelImpl
    private(set) var drivingViewModel: ButtonsAxisViewModelImpl
    private(set) var steeringViewModel: ButtonsAxisViewModelImpl

    private let model: BLEServoAdapter
    private let drivingSettings: ChannelSettingsData
    private let steeringSettings: ChannelSettingsData

    init(model: BLEServoAdapter, driving: ChannelSettingsData, steering: ChannelSettingsData) {
        self.model = model
        drivingSettings = driving
        steeringSettings = steering
        statusViewModel = StatusViewModelImpl(model: model)
        drivingViewModel = Self.makeAxisViewModel(settings: driving, model: model)
        steeringViewModel = Self.makeAxisViewModel(settings: steering, model: model)
    }

    func channelsDidChange() {
        drivingViewModel = Self.makeAxisViewModel(settings: drivingSettings, model: model)
        steeringViewModel = Self.makeAxisViewModel(settings: steeringSettings, model: model)
    }

    private static func makeAxisViewModel(
        settings: ChannelSettingsData,
        model: BLEServoAdapter
    ) -> ButtonsAxisViewModelImpl {
        ButtonsAxisViewModelImpl(
            model: channel(index: settings.channelIndex, in: model),
            config: settings.outputConfig,
            animationSpeed: settings.animationSpeed
        )
    }

    private static func channel(index: UInt8, in model: BLEServoAdapter) -> ServoChannelModel {
        guard Int(index) < model.channels.count else { return ServoChannelModelStub() }
        return model.channels[Int(index)]
    }
}
