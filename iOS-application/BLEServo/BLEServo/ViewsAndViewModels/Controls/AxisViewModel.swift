import Observation

@MainActor
@Observable
final class AxisViewModelImpl {
    let axisName: String
    private(set) var displayValue = ""

    var value: Float {
        get { valueInternal }
        set {
            animator.stopAnimation()
            guard newValue != valueInternal else { return }
            valueInternal = newValue
            updateDisplayValue()
            writePosition()
        }
    }

    private let model: ServoChannelModel
    private let converter: AxisConverter
    private let animator = ValueAnimator()
    private let animationSpeed: Float
    private var valueInternal = Float(0)

    init(model: ServoChannelModel, axisName: String, config: AxisOutputConfig, animationSpeed: Float) {
        self.model = model
        self.axisName = axisName
        self.animationSpeed = animationSpeed
        converter = AxisConverter(config)
        valueInternal = converter.servoToAxis(model.position)
        updateDisplayValue()
        animateToCenter()
    }

    func userInteractionDidEnd() {
        animateToCenter()
    }

    private func updateDisplayValue() {
        let axisValue = round(valueInternal * 100) / 100
        displayValue = "\(axisValue) / \(converter.axisToServo(valueInternal))"
    }

    private func writePosition() {
        model.position = converter.axisToServo(valueInternal)
    }

    private func animateToCenter() {
        animator.animate(from: valueInternal, to: 0, speed: animationSpeed) { [weak self] currentValue in
            guard let self else { return }
            valueInternal = currentValue
            updateDisplayValue()
            writePosition()
        }
    }
}
