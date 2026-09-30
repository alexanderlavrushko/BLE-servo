import Observation

@MainActor
@Observable
final class ChannelSettingsViewModelImpl {
    private let model: ChannelSettingsModel

    init(model: ChannelSettingsModel) {
        self.model = model
    }

    func updateMappingNegative(wantedValue: String?) -> String {
        if let value = UInt8(wantedValue) { model.data.outputConfig.maxNegative = value }
        return "\(model.data.outputConfig.maxNegative)"
    }

    func updateMappingCenter(wantedValue: String?) -> String {
        if let value = UInt8(wantedValue) { model.data.outputConfig.center = value }
        return "\(model.data.outputConfig.center)"
    }

    func updateMappingPositive(wantedValue: String?) -> String {
        if let value = UInt8(wantedValue) { model.data.outputConfig.maxPositive = value }
        return "\(model.data.outputConfig.maxPositive)"
    }

    func updateChannelIndex(wantedValue: String?) -> String {
        if let value = UInt8(wantedValue) { model.data.channelIndex = value }
        return "\(model.data.channelIndex)"
    }

    func updateAnimationSpeed(wantedValue: String?) -> String {
        if let value = Float(wantedValue, min: 0.1, max: 1000) { model.data.animationSpeed = value }
        return "\(model.data.animationSpeed)"
    }
}

private extension UInt8 {
    init?(_ text: String?) {
        guard let text, !text.isEmpty else { return nil }
        self.init(text)
    }
}

private extension Float {
    init?(_ text: String?, min: Float, max: Float) {
        guard let text, !text.isEmpty, let value = Float(text) else { return nil }
        self = value.clamped(min, max)
    }
}
