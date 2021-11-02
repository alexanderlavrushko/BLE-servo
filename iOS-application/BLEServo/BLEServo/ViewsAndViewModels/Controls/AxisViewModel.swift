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
            stopAnimation()
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
    private var valueInternal = Float(0)
    private var timer: Timer?

    init(model: ServoChannelModel, axisName: String, config: AxisOutputConfig) {
        self.model = model
        self.axisName = axisName
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

    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }

    func animateToCenter() {
        let interval = TimeInterval(1.0 / 60)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] (timer) in
            let wantedValue = Float(0)
            guard let self = self else {
                timer.invalidate()
                return
            }
            guard self.value != wantedValue else {
                timer.invalidate()
                self.stopAnimation()
                return
            }
            let difference = wantedValue - self.value
            let direction = Double(difference > 0 ? 1 : -1)
            let durationFromCenterToMax = TimeInterval(1)
            let deltaMove = Float(direction * interval / durationFromCenterToMax)

            let newValue = { () -> Float in
                if abs(deltaMove) < abs(difference) {
                    return self.value + deltaMove
                } else {
                    return wantedValue
                }
            }()
            self.valueInternal = newValue
            self.onValueDidChange?(self.value)
            self.updateDisplayValue()
            self.writePosition()

            if self.value == wantedValue {
                timer.invalidate()
            }
        }
    }
}
