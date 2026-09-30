import Observation

@MainActor
@Observable
final class SettingsViewModelImpl {
    var controlTypeIndex: Int
    private(set) var revision = 0

    var drivingViewModel: ChannelSettingsViewModelImpl { drivingImpl }
    var steeringViewModel: ChannelSettingsViewModelImpl { steeringImpl }

    private let model: SettingsModel
    private let drivingImpl: ChannelSettingsViewModelImpl
    private let steeringImpl: ChannelSettingsViewModelImpl

    init(model: SettingsModel) {
        self.model = model
        controlTypeIndex = ControlTypeIndex(model.controlType).rawValue
        drivingImpl = ChannelSettingsViewModelImpl(model: model.drivingModel)
        steeringImpl = ChannelSettingsViewModelImpl(model: model.steeringModel)
    }

    func updateControlType(_ index: Int) {
        guard let controlType = ControlTypeIndex(rawValue: index) else { return }
        controlTypeIndex = index
        model.controlType = controlType.controlType
    }

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
        reload()
    }

    func resetToDefaults() {
        model.resetToDefaults()
        reload()
    }

    private func reload() {
        controlTypeIndex = ControlTypeIndex(model.controlType).rawValue
        revision += 1
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
}
