//
//  AxisViewModel.swift
//  BLEServo
//
//  Created by Alexander Lavrushko on 30/10/2021.
//

import Foundation

/// This protocol defines how View communicates with ViewModel. Just to make the dependency clear.
protocol AxisViewModel: AnyObject {
    var axisName: String { get }
    var value: Float { get set }
    var onValueDidChange: ((Float) -> Void)? { get set }
    var displayValue: String { get }
    var onDisplayValueDidChange: ((String) -> Void)? { get set }
    func userInteractionDidEnd()
}

class AxisViewModelImpl: AxisViewModel {
    // MARK: - AxisViewModel implementation
    let axisName: String
    var value: Float {
        get { valueInternal }
        set {
            animator.stopAnimation()
            guard newValue != value else { return }
            valueInternal = newValue
            updateDisplayValue()
            writePosition()
        }
    }
    var onValueDidChange: ((Float) -> Void)?
    var displayValue: String = "" {
        didSet {
            guard displayValue != oldValue else { return }
            onDisplayValueDidChange?(displayValue)
        }
    }
    var onDisplayValueDidChange: ((String) -> Void)?
    func userInteractionDidEnd() {
        animateToCenter()
    }

    // MARK: - Internal logic
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
        connectToModel()
        updateDisplayValue()
        animateToCenter()
    }
}

private extension AxisViewModelImpl {
    func connectToModel() {
        valueInternal = converter.servoToAxis(model.position)
    }

    func updateDisplayValue() {
        let value = round(self.value * 100) / 100
        let outputValue = converter.axisToServo(self.value)
        displayValue = "\(value) / \(outputValue)"
    }

    func writePosition() {
        model.position = converter.axisToServo(value)
    }

    func animateToCenter() {
        animator.animate(from: value, to: 0, speed: animationSpeed) { [weak self] (currentValue) in
            guard let self = self else { return }
            self.valueInternal = currentValue
            self.onValueDidChange?(self.value)
            self.updateDisplayValue()
            self.writePosition()
        }
    }
}
