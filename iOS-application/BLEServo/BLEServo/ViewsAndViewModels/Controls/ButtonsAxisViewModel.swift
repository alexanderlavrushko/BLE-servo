import Observation

@MainActor
@Observable
final class ButtonsAxisViewModelImpl {
    private(set) var value: Float {
        didSet {
            guard value != oldValue else { return }
            model.position = converter.axisToServo(value)
        }
    }

    private let model: ServoChannelModel
    private let converter: AxisConverter
    private let animator = ValueAnimator()
    private let animationSpeed: Float

    init(model: ServoChannelModel, config: AxisOutputConfig, animationSpeed: Float) {
        self.model = model
        self.animationSpeed = animationSpeed
        converter = AxisConverter(config)
        value = converter.servoToAxis(model.position)
        animateValue(to: 0)
    }

    func positiveButtonDidPress() {
        if value < 0 { value = 0 }
        animateValue(to: 1)
    }

    func positiveButtonDidRelease() {
        animateValue(to: 0)
    }

    func negativeButtonDidPress() {
        if value > 0 { value = 0 }
        animateValue(to: -1)
    }

    func negativeButtonDidRelease() {
        animateValue(to: 0)
    }

    private func animateValue(to wantedValue: Float) {
        animator.animate(from: value, to: wantedValue, speed: animationSpeed) { [weak self] currentValue in
            self?.value = currentValue
        }
    }
}
